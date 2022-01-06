

def black_box_function(**p):
    """Function with unknown internals we wish to maximize.

    This is just serving as an example, for all intents and
    purposes think of the internals of this function, i.e.: the process
    which generates its output values, as unknown.
    """
    test1 = 0
    test = [];
    for i in range(3):
        key = "p" + str(i)
        test.append(p[key])
    meep = test[0]; mawp = test[1];
    x = 0
    y = 1
    return -x ** 2 - (y - 1) ** 2 + 1 + meep + mawp


# ## 2. Getting Started
# 
# All we need to get started is to instanciate a `BayesianOptimization` object specifying a function to be optimized `f`, and its parameters with their corresponding bounds, `pbounds`. This is a constrained optimization technique, so you must specify the minimum and maximum values that can be probed for each parameter in order for it to work

# In[2]:


from bayes_opt import BayesianOptimization


# In[3]:


# Bounded region of parameter space
pbounds = {}
key = []

for i in range(3):
    key.append('p' + str(i))

bounds = (1,5)
for i in key:
    pbounds[i] = bounds


#pbounds = {'p' : (1, 5)}

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
    n_iter=20,
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
