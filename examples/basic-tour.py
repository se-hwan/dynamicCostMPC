#!/usr/bin/env python
# coding: utf-8

# # Basic tour of the Bayesian Optimization package
# 
# This is a constrained global optimization package built upon bayesian inference and gaussian process, that attempts to find the maximum value of an unknown function in as few iterations as possible. This technique is particularly suited for optimization of high cost functions, situations where the balance between exploration and exploitation is important.
# 
# Bayesian optimization works by constructing a posterior distribution of functions (gaussian process) that best describes the function you want to optimize. As the number of observations grows, the posterior distribution improves, and the algorithm becomes more certain of which regions in parameter space are worth exploring and which are not, as seen in the picture below.
# 
# As you iterate over and over, the algorithm balances its needs of exploration and exploitation taking into account what it knows about the target function. At each step a Gaussian Process is fitted to the known samples (points previously explored), and the posterior distribution, combined with a exploration strategy (such as UCB (Upper Confidence Bound), or EI (Expected Improvement)), are used to determine the next point that should be explored (see the gif below).
# 
# This process is designed to minimize the number of steps required to find a combination of parameters that are close to the optimal combination. To do so, this method uses a proxy optimization problem (finding the maximum of the acquisition function) that, albeit still a hard problem, is cheaper (in the computational sense) and common tools can be employed. Therefore Bayesian Optimization is most adequate for situations where sampling the function to be optimized is a very expensive endeavor. See the references for a proper discussion of this method.

# ## 1. Specifying the function to be optimized
# 
# This is a function optimization package, therefore the first and most important ingreedient is, of course, the function to be optimized.
# 
# **DISCLAIMER:** We know exactly how the output of the function below depends on its parameter. Obviously this is just an example, and you shouldn't expect to know it in a real scenario. However, it should be clear that you don't need to. All you need in order to use this package (and more generally, this technique) is a function `f` that takes a known set of parameters and outputs a real number.

# In[1]:


def black_box_function(x, y):
    """Function with unknown internals we wish to maximize.

    This is just serving as an example, for all intents and
    purposes think of the internals of this function, i.e.: the process
    which generates its output values, as unknown.
    """
    return -x ** 2 - (y - 1) ** 2 + 1


# ## 2. Getting Started
# 
# All we need to get started is to instanciate a `BayesianOptimization` object specifying a function to be optimized `f`, and its parameters with their corresponding bounds, `pbounds`. This is a constrained optimization technique, so you must specify the minimum and maximum values that can be probed for each parameter in order for it to work

# In[2]:


from bayes_opt import BayesianOptimization


# In[3]:


# Bounded region of parameter space
pbounds = {'x': (2, 4), 'y': (-3, 3)}


# In[4]:


optimizer = BayesianOptimization(
    f=black_box_function,
    pbounds=pbounds,
    verbose=2, # verbose = 1 prints only when a maximum is observed, verbose = 0 is silent
    random_state=1,
)


# The BayesianOptimization object will work out of the box without much tuning needed. The main method you should be aware of is `maximize`, which does exactly what you think it does.
# 
# There are many parameters you can pass to maximize, nonetheless, the most important ones are:
# - `n_iter`: How many steps of bayesian optimization you want to perform. The more steps the more likely to find a good maximum you are.
# - `init_points`: How many steps of **random** exploration you want to perform. Random exploration can help by diversifying the exploration space.

# In[5]:


optimizer.maximize(
    init_points=2,
    n_iter=3,
)


# The best combination of parameters and target value found can be accessed via the property `bo.max`.

# In[6]:


print(optimizer.max)


# While the list of all parameters probed and their corresponding target values is available via the property `bo.res`.

# In[7]:


for i, res in enumerate(optimizer.res):
    print("Iteration {}: \n\t{}".format(i, res))


# ### 2.1 Changing bounds
# 
# During the optimization process you may realize the bounds chosen for some parameters are not adequate. For these situations you can invoke the method `set_bounds` to alter them. You can pass any combination of **existing** parameters and their associated new bounds.

# In[8]:


optimizer.set_bounds(new_bounds={"x": (-2, 3)})


# In[9]:


optimizer.maximize(
    init_points=0,
    n_iter=5,
)


# ## 3. Guiding the optimization
# 
# It is often the case that we have an idea of regions of the parameter space where the maximum of our function might lie. For these situations the `BayesianOptimization` object allows the user to specify specific points to be probed. By default these will be explored lazily (`lazy=True`), meaning these points will be evaluated only the next time you call `maximize`. This probing process happens before the gaussian process takes over.
# 
# Parameters can be passed as dictionaries such as below:

# In[10]:


optimizer.probe(
    params={"x": 0.5, "y": 0.7},
    lazy=True,
)


# Or as an iterable. Beware that the order has to be alphabetical. You can usee `optimizer.space.keys` for guidance

# In[11]:


print(optimizer.space.keys)


# In[12]:


optimizer.probe(
    params=[-0.3, 0.1],
    lazy=True,
)


# In[13]:


optimizer.maximize(init_points=0, n_iter=0)


# ## 4. Saving, loading and restarting
# 
# By default you can follow the progress of your optimization by setting `verbose>0` when instanciating the `BayesianOptimization` object. If you need more control over logging/alerting you will need to use an observer. For more information about observers checkout the advanced tour notebook. Here we will only see how to use the native `JSONLogger` object to save to and load progress from files.
# 
# ### 4.1 Saving progress

# In[14]:


from bayes_opt.logger import JSONLogger
from bayes_opt.event import Events


# The observer paradigm works by:
# 1. Instantiating an observer object.
# 2. Tying the observer object to a particular event fired by an optimizer.
# 
# The `BayesianOptimization` object fires a number of internal events during optimization, in particular, everytime it probes the function and obtains a new parameter-target combination it will fire an `Events.OPTIMIZATION_STEP` event, which our logger will listen to.
# 
# **Caveat:** The logger will not look back at previously probed points.

# In[15]:


logger = JSONLogger(path="./logs.json")
optimizer.subscribe(Events.OPTIMIZATION_STEP, logger)


# In[16]:


optimizer.maximize(
    init_points=2,
    n_iter=3,
)


# ### 4.2 Loading progress
# 
# Naturally, if you stored progress you will be able to load that onto a new instance of `BayesianOptimization`. The easiest way to do it is by invoking the `load_logs` function, from the `util` submodule.

# In[17]:


from bayes_opt.util import load_logs


# In[18]:


new_optimizer = BayesianOptimization(
    f=black_box_function,
    pbounds={"x": (-2, 2), "y": (-2, 2)},
    verbose=2,
    random_state=7,
)
print(len(new_optimizer.space))


# In[19]:


load_logs(new_optimizer, logs=["./logs.json"]);


# In[20]:


print("New optimizer is now aware of {} points.".format(len(new_optimizer.space)))


# In[21]:


new_optimizer.maximize(
    init_points=0,
    n_iter=10,
)


# ## Next Steps
# 
# This tour should be enough to cover most usage scenarios of this package. If, however, you feel like you need to know more, please checkout the `advanced-tour` notebook. There you will be able to find other, more advanced features of this package that could be what you're looking for. Also, browse the examples folder for implementation tips and ideas.
