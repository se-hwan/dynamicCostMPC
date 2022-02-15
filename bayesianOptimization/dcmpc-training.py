import sys, os, shutil
import time, datetime
import yaml, csv
import lcm
import numpy as np
sys.path.append('./lcm')
sys.path.append('../../config')
from dcmpc_reward_lcmt import dcmpc_reward_lcmt
from dcmpc_parametrization_lcmt import dcmpc_parametrization_lcmt
from bayes_opt import BayesianOptimization, UtilityFunction
from bayes_opt.logger import JSONLogger
from bayes_opt.event import Events

global reward, lc, msg, steady_state

steady_state = 0

# receives reward messages from Robot-Software after single simulation terminates
def my_handler(channel, data):
    msg = dcmpc_reward_lcmt.decode(data)
    global reward, steady_state
    reward = msg.reward
    if (msg.steady_state):
        steady_state += 1

# sends parameters to Robot-Software based on chosen acquisition function
def RobotSoftwareSimulation(**p):
    param = []
    for i in range(len(p)):
        key = 'p' + '{:0>2}'.format(i)
        param.append(p[key])
        msg.Q_diag[i] = param[i]
    lc.publish("DCMPC_PARAM", msg.encode())
    lc.handle()
    return reward

lc = lcm.LCM()
subscription = lc.subscribe("DCMPC_REWARDS", my_handler)    # incoming messages from Robot-Software (rewards)
msg = dcmpc_parametrization_lcmt()                          # messages to output to Robot-Software (parameters)

# create timestamped folders for data collection
folder_name_BO = os.path.join(os.getcwd() + "/data/BO", datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
folder_name_RS = os.path.join(os.getcwd() + "/data/RS", datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))
os.makedirs(folder_name_BO)
os.makedirs(folder_name_RS)
shutil.copy('./data/cmd_sweep.csv', folder_name_BO+'/cmd_sweep.csv')
shutil.copy('./data/cmd_sweep.csv', folder_name_RS+'/cmd_sweep.csv')
print('Folders for data created.')

# read in desired velocity commands from csv generated by MATLAB
commands = []
command_count = 0
with open('./data/cmd_sweep.csv',newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        commands.append(row)
        command_count += 1

# choose desired rate of increase in commands
ramp_rate = [0.5, 0.5, 1.0]

# number of initial (random) points and maximum points to evalute
iter_rand = 50
iter_max = 250

print('Sweep over velocity commands successfully loaded! ', command_count, ' velocity commands are prepared.')
print('Commands set to increase at rate: ', ramp_rate)
print('Beginning Bayesian optimization process...')
print('Random initial points to evaluate: ', iter_rand)
print('Maximum points to evaluate: ', iter_max)


for cmd_idx in range(0, command_count):

    t = time.time()

    # overwrite yaml file with new commands
    with open('../../config/DCMPC-training.yaml') as f:
        list_doc = yaml.safe_load(f)
    list_doc['training_cmd'] = commands[cmd_idx]
    sign = [0, 0, 0]
    for c in range(0, 3):
        if (float(commands[cmd_idx][c]) < 0.):
            sign[c] = -1
        else:
            sign[c] = 1
    list_doc['ramp_up_rate'] = [sign[0]*ramp_rate[0], sign[1]*ramp_rate[1], sign[2]*ramp_rate[2]]
    with open('../../config/DCMPC-training.yaml','w') as f:
        yaml.dump(list_doc, f, default_flow_style=False)
    print("Velocity command: ", commands[cmd_idx])

    # setup Bayesian optimization process
    p_bounds = {}
    key = []
    n_params = 12
    for i in range(n_params):
        param_id = 'p' + '{:0>2}'.format(i)
        key.append(param_id)

    bounds = (0, 100)
    for i in key:
        p_bounds[i] = bounds 

    optimizer = BayesianOptimization(f=RobotSoftwareSimulation,
                                     pbounds=p_bounds,
                                     verbose=2,
                                     random_state=1)

    # setup data filenames
    file_name_BO = folder_name_BO + "/cmd_sweep_" + str(cmd_idx+1)
    file_name_RS = folder_name_RS + "/cmd_sweep_" + str(cmd_idx+1) 
    logger = JSONLogger(path=file_name_BO+'.json')
    optimizer.subscribe(Events.OPTIMIZATION_STEP, logger)
    
    utility = UtilityFunction(kind="ucb", kappa=2.5, xi=0.0)

    optimizer._prime_queue(iter_rand)

    eps = 1e-3
    iteration = 0
    max_target = 999
    while not optimizer._queue.empty or iteration < iter_max:
        target = 0
        try:
            x_probe = next(optimizer._queue)
            optimizer.probe(x_probe, lazy=False)
            print("Max value from random search: %6.5f" % (optimizer.max['target']))
        except StopIteration:
            utility.update_params()
            x_probe = optimizer.suggest(utility)
            target = RobotSoftwareSimulation(**x_probe)
            optimizer.register(params=x_probe, target=target)
            print("Iteration: %3d Target value: %6.5f" % (iteration+1, target))
            iteration += 1
        if (abs(max_target - target) < eps and iteration > 20):
            print("Improvement tolerance reached, exiting loop...")
            break
        max_target = optimizer.max['target']
    optimizer.dispatch(Events.OPTIMIZATION_END)

    print("Bayesian optimization complete! Saving results...")
    os.replace('./data/RS/DCMPC_sim_data.bin', file_name_RS+'.bin')
    if (steady_state < 0.5): # rename file if steady state velocity command not reached
        os.rename(file_name_BO+'.json', file_name_BO + '_fail.json')
        os.rename(file_name_RS+'.bin', file_name_RS + '_fail.bin')

    # output total time taken for one iteration of velocity command
    elapsed = time.time() - t
    print("Time taken for iteration ", cmd_idx+1, ": ", elapsed, " s")
    
    # reset steady state flag
    steady_state = 0


    
'''
    for idx in range(iter_rand):
        rand_point = next(optimizer._queue)
        optimizer.probe()
        target = RobotSoftwareSimulation(**rand_point)
        optimizer.register(params=rand_point, target=target)
        print("Iteration: %3d Target value: %6.5" % (idx, target))
    
    for idx in range(iter_rand, iter_max):
        next_point = optimizer.suggest(utility)
        target = RobotSoftwareSimulation(**next_point)
        optimizer.register(params=next_point, target=target)
        print("Iteration: %3d Target value: %6.5" % (idx, target))
'''