# Hydrogen Embrittlement: Research Log

**Bibek Magar**

## Derivation of Hydrogen Transport Equation

The diffusion is based on Sofronis and McMeeking's paper, which uses an equilibrium theory established by Oriani. Hydrogen moves through the material by normal interstitial lattice site (NILS) diffusion. Transported hydrogen is located either din NILS or in trap sites. The hydrogen concentrations in NILS and trap sites are described below respectively:

$$
C_L = \theta_L N_L
$$

$$
C_T = \theta_T N_T
$$

Where $\theta_L$ and $\theta_T$ are respectively the occupancy of lattice sites and the occupancy of trap sites. $N_L$ and $N_T$ are the lattice site and trap site densities respectively.

Total Hydrogen Concentration $C$ = $C_L + \sum_i C_T^{(i)}$, Where $i$ represents the different trap sites. For convenience, let us consider dislocation trap site which evolves with mechanical deformation.

$$
C(C_L, C_T) = C_L + C_T
$$

We have,

$$
\frac{\partial C}{\partial C_L} = 1;   \frac{\partial C}{\partial C_T} = 1
$$

Then,

$$
\frac{\partial C}{\partial t} = \frac{\partial C_L}{\partial t} + \frac{\partial C_T}{\partial t}
$$

Using chain rule we get,

$$
\frac{\partial C}{\partial t} = \frac{\partial C}{\partial C_L} \frac{\partial C_L}{\partial t} + \frac{\partial C}{\partial C_T} \frac{\partial C_T}{\partial t}
$$

Considering $i$ types of trap sites,

$$
\frac{\partial C}{\partial t} = \frac{\partial C}{\partial C_L} \frac{\partial C_L}{\partial t} + \sum_i \frac{\partial C}{\partial C_T^{(i)}} \frac{\partial C_T^{(i)}}{\partial t}
$$

### Oriani's Equilibrium Theory

It gives relationship between the occupancy of the $i^{th}$ type of trapping sites and the fraction of occupied lattice sites,

$$
\frac{\theta_T^{(i)}}{1 - \theta_T^{(i)}} = \left( \frac{\theta_L}{1 - \theta_L} \right) K^{(i)}
$$

$$
K^{(i)} = e^{\left( \frac{- W_B^{(i)}}{R T} \right)}
$$

Where,

$K^{(i)}$ = Equilibrium constant for $i^{th}$ type of trap
$W_B^{(i)}$ = Binding Energy for $i^{th}$ type of trap
$R$ = Gas constant
$T$ = Absolute temperature

For $\theta_L << 1$,

$$
\frac{\theta_L}{1 - \theta_L} \approx \theta_L
$$

And consequently,

$$
C_T^{(i)} = \frac{ K^{(i)} C_L N_T^{(i)}}{N_L + C_L  K^{(i)}}
$$

The above equation characterizes the equilibrium relationship between $C_L$ and $C_T$ in terms of material parameters. Thus, as temperature and $K$ decreases, the concentration of hydrogen in traps will decrease for a fixed $C_L$.

Also,

$$
\frac{\partial C_T^{(i)}}{\partial C_L} = \frac{ K^{(i)} N_L N_T^{(i)}}{(N_L + C_L  K^{(i)})^2}
$$

$\frac{\partial C_T^{(i)}}{\partial C_L}$ gives some insight into the process of equilibrium trap-fillings at fixed temperature and $N_T$.

### Hydrogen Lattice Diffusion

Chemical potential gradients constitute the driving force for this diffusion. At low concentrations, at which there is no interaction between the diffusing species and the rate of diffusion depends only on hydrogen flux $J$ to the gradient of the chemical potential flow $\mu$ as follows:

$$
J = - \frac{D C_L}{RT} \nabla \mu
$$

Where, $D$ is the lattice diffusion constant that is assumed to be independent of stress, $R$ is the gas constant, and $T$ is the absolute temperature.

In general, for a system under external stress and in conditions in which the above equation is valid. At constant pressure and temperature,

$$
\mu = \mu^0 + R T \ln{\frac{\theta_L}{1 - \theta_L}} - \bar{V_H} \sigma_H
$$

Where, $\mu^0$ denotes the chemical potential in the standard state, $\bar{V_H}$ partial molar volume of hydrogen in solid solution, and $\sigma_H$ is the hydrostatic stress. Substituting the value of $\mu$ we get,

$$
J = - D \nabla C_L + \frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H
$$

### Dislocation Trapping Schemes

It is assumed so far that the trap density is a material property that remains constant throughout the analysis. This is appropriate for most trap types but not dislocation trapping sites, as the dislocation density evolves with the applied load.For pure iron, Kumnick and Johnson & Sofronis and McMeeking model gives a relationship between $N_T$ and $\epsilon_P$ (Equivalent Plastic Strain) as follow:

$$
N_T = 10^{23.6 - 2.33 \exp{(-5.5 \epsilon^P)}} [sites/ m^3]
$$

A factor depending on the strain rate should be included to ensure a correct hydrogen balance. Consider for simplicity a one-trap model. As the concentration of trapped hydrogen $C_T$ depends on the trap density $N_T$ , and the latter depends on the plastic deformation, by means of the chain rule one reaches:

$$
\frac{\partial C_T}{\partial t} = \frac{\partial C_T}{\partial C_L} \frac{\partial C_L}{\partial t} + \frac{\partial C_T}{\partial N_T} \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t}
$$

With,

$$
\frac{\partial C_T}{\partial C_L} = \frac{C_T (1 - \theta_T)}{C_L}
$$

$$
\frac{\partial C_T}{\partial N_T} = \theta_T
$$

Ultimately,

$$
\frac{\partial C_T}{\partial t} = \frac{C_T (1 - \theta_T)}{C_L} \frac{\partial C_L}{\partial t} + \theta_T \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t}
$$

### Mass Balance Equation

$$
\frac{d}{dt} \int_V (C_L + C_T) dV + \int_S J . n \ dS = 0
$$

Using Divergence theorem we get,

$$
\frac{d}{dt} \int_V (C_L + C_T) dV + \int_V \nabla . J \ dV = 0
$$

$$
\int_V \left( \frac{\partial C_L}{\partial t} + \frac{\partial C_T}{\partial t} + \nabla . J \right) dV = 0
$$

$$
\frac{\partial C_L}{\partial t} + \frac{\partial C_T}{\partial t} + \nabla . J = 0
$$

$$
\frac{\partial C_L}{\partial t} + \frac{C_T (1 - \theta_T)}{C_L} \frac{\partial C_L}{\partial t} + \theta_T \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t} + \nabla . \left( - D \nabla C_L + \frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H  \right) = 0
$$

$$
\left( \frac{C_L + C_T (1 - \theta_T)}{C_L} \right) \frac{\partial C_L}{\partial t} - \nabla . (D \nabla C_L) + \nabla . \left( \frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H \right) + \theta_T \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t} = 0
$$

## Hydrogen Transport Equation: Strong Form

$$
\boxed{\left( \frac{C_L + \sum_i C_T^{(i)}(1 -\theta_T^{(i)})}{C_L} \right) \frac {\partial C_L}{\partial t} + \nabla . (D \nabla C_L) + \nabla . \left( \frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H \right) + \theta_T \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t} = 0}
$$

## Updating $C_L$ and $C$

Since $C_L$ is our field variable (degree of freedom), updating it is fairly simple,

$$
\boxed{C_L(t + \Delta t) = C_L(t) + \Delta C_L}
$$

For $C$,

$$
\frac{\partial C}{\partial t} = \frac{\partial C}{\partial C_T} \frac{\partial C_T}{\partial t}
$$

$$
= \frac{\partial C}{\partial C_T} \left( \frac{\partial C_T}{\partial C_L} \frac{\partial C_L}{\partial t} + \frac{\partial C_T}{\partial N_T} \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t} \right) \; [using \; (the trapped-concentration rate equation)]
$$

$$
\therefore \frac{\partial C}{\partial t} = \frac{\partial C}{\partial C_L} \frac{\partial C_L}{\partial t} + \frac{\partial C}{\partial N_T} \frac{\partial N_T}{\partial \epsilon_P} \frac{\partial \epsilon_P}{\partial t}
$$

where,

$$
\frac{\partial C}{\partial N_T} = \frac{\partial C_L + \partial C_T}{\partial t} = \frac{K C_L}{K C_L + N_L}
$$

$$
\frac{\partial N_T}{\partial \epsilon_P} = 29.5 e^{(-5.5 \epsilon_P)} N_T
$$

Now,

$$
C(t + \Delta t) = C(t) + \Delta C
$$

$$
= C(t) + \frac{\partial C}{\partial t} \Delta t \; \; \;[\because \Delta a = \dot{a} \Delta t]
$$

$$
= C(t) + \left( \frac{\partial C}{\partial C_L} \frac{\partial C_L}{\partial t} + \frac{\partial C}{\partial N_T} \frac{\partial N_T}{\partial \epsilon_P} \frac{\partial \epsilon_P}{\partial t} \right) \Delta t \; \; \; [using \; (the total-concentration rate equation)]
$$

$$
= C(t) + \frac{\partial C}{\partial C_L} \frac{\partial C_L}{\partial t} \Delta t + \frac{\partial C}{\partial N_T} \frac{\partial N_T}{\partial \epsilon_P} \frac{\partial \epsilon_P}{\partial t} \Delta t
$$

$$
\boxed{\therefore C(t + \Delta t) = C(t) + \frac{\partial C}{\partial C_L} \Delta C_L + \frac{\partial C}{\partial N_T} \frac{\partial N_T}{\partial \epsilon_P} \Delta \epsilon_P \; \; \; [\because \Delta a = \dot{a} \Delta t]}
$$

where,

$$
\frac{\partial C}{\partial C_L} = \frac{\partial C_L}{\partial C_L} + \sum_i \frac{C_T^{(i)} ( 1 - \theta_T^{(i)})}{C_L} = 1 + \frac{K^{(i)} N_L N_T^{(i)}}{\left(K^{(i)} C_L + N_L\right)^2}
$$

## Weak Formulation of Hydrogen Transport Equation: MOOSE Implementation

### Kernel 1: Time Derivative Term

$$
\boxed{\int_\Omega \phi \left[ \left( \frac{C_L + \sum_i C_T^{(i)}(1 -\theta_T^{(i)})}{C_L} \right) \frac {\partial C_L}{\partial t} \right] d\Omega}
$$

### Kernel 2: Fick's Diffusion Term

$- \int_\Omega \phi \left[\nabla . \left(D \nabla C_L\right)\right] d\Omega$
$= \underbrace{- \int_{d \Omega}\phi \left( D \nabla C_L . n \right) d\Gamma }_{BCs} + \underbrace{\int_\Omega \nabla \phi . \left(D \nabla C_L\right) d\Omega}_{Kernel}$

$$
\boxed{\int_\Omega \nabla \phi . \left(D \nabla C_L\right) d\Omega}
$$

### Kernel 3: Stress Assisted Diffusion Term

$\int_\Omega \phi \left[ \nabla . \left(\frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H\right) \right] d\Omega$
$= \underbrace{\int_{d \Omega} \phi \left[ \left(\frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H\right) . n \right] d\Gamma}_{BCs} - \underbrace{\int_\Omega \nabla \phi . \left(\frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H\right) d\Omega}_{Kernel}$

$$
\boxed{ - \int_\Omega \nabla \phi . \left(\frac{D \bar{V_H}}{R T} C_L \nabla \sigma_H\right) d\Omega}
$$

### Kernel 4: Plastic Strain Induced Dislocation Trapping Term

$$
\boxed{\int_\Omega \phi \left( \theta_T \frac{d N_T}{d \epsilon_P }\frac{d \epsilon_P}{d t} \right) d\Omega}
$$

