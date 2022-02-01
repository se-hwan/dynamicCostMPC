import sys, os
import yaml, csv
import lcm
import numpy as np
sys.path.append('./lcm')
sys.path.append('../../config')
from dcmpc_reward_lcmt import dcmpc_reward_lcmt
from dcmpc_parametrization_lcmt import dcmpc_parametrization_lcmt
from bayes_opt import BayesianOptimization
from bayes_opt.logger import JSONLogger
from bayes_opt.event import Events

global reward, lc, msg, steady_state

steady_state = 0

def my_handler(channel, data):
    msg = dcmpc_reward_lcmt.decode(data)
    global reward, steady_state
    reward = msg.survival_time
    if (msg.steady_state):
        steady_state += 1

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

commands = []
command_count = 0
with open('./data/cmd_sweep.csv',newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        commands.append(row)
        command_count += 1

ramp_rate = [0.5, 0.5, 1.0]

print('Sweep over velocity commands successfully loaded! ', command_count, ' velocity commands are prepared.')
print('Commands set to increase at rate: ', ramp_rate)
print('Beginning Bayesian optimization process...')

for cmd_idx in range(0, command_count):
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
    optimizer.maximize(init_points=0, n_iter=0)
    path_name_BO = "./data/BO/cmd_sweep_" + str(cmd_idx)
    path_name_RS = "./data/RS/cmd_sweep_" + str(cmd_idx) 
    logger = JSONLogger(path=path_name_BO+'.json')
    optimizer.subscribe(Events.OPTIMIZATION_STEP, logger)
    optimizer.maximize(init_points=1, n_iter=5, acq="ei", xi=1e-4)

    print("Bayesian optimization complete! Saving results...")
    os.rename('./data/RS/DCMPC_sim_data.bin', path_name_RS+'.bin')
    if (steady_state < 0.5):
        os.rename(path_name_BO+'.json', path_name_BO + '_fail.json')
        os.rename(path_name_RS+'.bin', path_name_RS + '_fail.bin')


