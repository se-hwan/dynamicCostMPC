import lcm
from dcmpc_reward_lcmt import dcmpc_reward_lcmt
from dcmpc_parametrization_lcmt import dcmpc_parametrization_lcmt
from bayes_opt import BayesianOptimization

global reward

def my_handler(channel, data):
    msg = dcmpc_reward_lcmt.decode(data)
    print("Received message on channel \"%s\"" % channel)
    print("   gravity   = %s" % str(msg.survival_time))
    print("")
    global reward 
    reward = msg.survival_time

def RobotSoftwareSimulation(parameters):
    lc.handle()

    # calculate reward from LCM messages, if needed
    return reward

def publishParameters(lc, msg):  # publishes parameters to Robot-Software
    for i in range(0, 12):
        msg.Q_diag[i] = 1;
    msg.test = 1.0;
    lc.publish("DCMPC_PARAM", msg.encode())

lc = lcm.LCM()
subscription = lc.subscribe("DCMPC_REWARDS", my_handler)    # incoming messages from Robot-Software (rewards)
msg = dcmpc_parametrization_lcmt()                          # messages to output to Robot-Software (parameters)

p_bounds = {}
n_params = 12
for i in range(n_params):
    p_bounds[i]
bounds = (-50, 50)
for i in n_params:
    p_bounds[i] = bounds 


while(1): # main loop
    lc.handle()   # receive lcm message
    print("survival time: ", reward)
    # bayesian optimization calculation
    # determine next parameter to evaluate
    print("Publishing message")
    publishParameters(lc, msg)


