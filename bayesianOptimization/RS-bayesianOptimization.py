import sys
import lcm
sys.path.insert(0, './lcm')
from dcmpc_reward_lcmt import dcmpc_reward_lcmt
from dcmpc_parametrization_lcmt import dcmpc_parametrization_lcmt
from bayes_opt import BayesianOptimization
from bayes_opt.logger import JSONLogger
from bayes_opt.event import Events

global reward, lc, msg

def my_handler(channel, data):
    msg = dcmpc_reward_lcmt.decode(data)
    global reward
    reward = msg.survival_time

def RobotSoftwareSimulation(**p):
    param = []
    for i in range(len(p)):
        key = 'p' + '{:0>2}'.format(i);
        param.append(p[key]);
        msg.Q_diag[i] = param[i];
        #msg.Q_alpha[i] = param[i];
        #msg.Q_PN[i] = param[i];
    lc.publish("DCMPC_PARAM", msg.encode())
    lc.handle()
    return reward

lc = lcm.LCM()
subscription = lc.subscribe("DCMPC_REWARDS", my_handler)    # incoming messages from Robot-Software (rewards)
msg = dcmpc_parametrization_lcmt()                          # messages to output to Robot-Software (parameters)

p_bounds = {}
key = []
n_params = 12
for i in range(n_params):
    param_id = 'p' + '{:0>2}'.format(i);
    key.append(param_id)

bounds = (0, 100)
for i in key:
    p_bounds[i] = bounds 

optimizer = BayesianOptimization(f=RobotSoftwareSimulation,
                                 pbounds=p_bounds,
                                 verbose=2,
                                 random_state=1)
optimizer.maximize(init_points=0, n_iter=0)
logger = JSONLogger(path="./data/logs.json")
optimizer.subscribe(Events.OPTIMIZATION_STEP, logger)
optimizer.maximize(init_points=100, n_iter=5000, acq="ei", xi=1e-4)
