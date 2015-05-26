---
title: "tree: A package for modelling plant TRait Ecology & Evolution: _Useful derivations_"
---

# Derivation of PDE describing size-structured dynamics
TODO: Change $m \rightarrow h$?

To model the population we use a PDE describing the dynamics for a thin slice $\Delta m$. Assuming that all rates are constant within the interval $\Delta m$, the total number of individuals within the interval spanned by $[m-0.5\Delta m,m+0.5\Delta m)$ is $n(m,a)\Delta m$ . The flux of individuals in and out of the size class can be expressed as
\begin{equation}\begin{array}{ll} J(m,a)=&g(m-0.5 \Delta m,a) \; n(m-0.5 \Delta m,a)-g(m+0.5 \Delta m,a) \; n(m+0.5 \Delta m,a) \\ &-d (m,a) \; n(m,a)\Delta m\\ \end{array}.
\end{equation}
The first two terms describe the flux in and out of the size class through growth; the last term describes lossed due through mortality. The change in number of individuals within the interval across a time step \textit{$\Delta $t} is thus:
\begin{equation}
  \begin{array}{ll} n(m,a+\Delta a)\Delta m-n(m,a)\Delta m= &g(m-0.5 \Delta m,a) \; n(m-0.5 \Delta m,a)\Delta a \\ &-g(m+0.5 \Delta m,a) \; n(m+0.5 \Delta m,a)\Delta a\\&-d (m,a) \; n(m,a)\Delta m\Delta a.
  \end{array}
\end{equation}
Rearranging,
\begin{equation}
  \begin{array}{ll}
  \frac{n(m,a+\Delta a)-n(m,a)}{\Delta a} = &-d (m,a) \; n(m,a) \\
  &-\frac{g(m+0.5 \Delta m,a) \; n(m+0.5 \Delta m,a)-g(m-0.5 \Delta m,a) \; n(m-0.5 \Delta m,a)}{\Delta m}.
  \end{array}
\end{equation}
The LHS is corresponds to the derivative of $n$ as $\Delta a\to 0$. For thin slices, $\Delta m\sim 0$, we obtain
\begin{equation} \label{eq:PDE-app}
  \frac{\partial }{\partial t} n(m,a)=-d (m,a) \; n(m,a)-\frac{\partial }{\partial m} (g(m,a) \; n(m,a)).
\end{equation}

To complete the model, the PDE must be supplemented with boundary conditions that specify the density at the lower end of $n(m_{0},a)$ for all $t$ as well as the the initial distribution when $t=0$, $n(m,0)$.  The former is derived by integrating the PDE with respect to $h$ over the interval $(m_{0},m_{\infty })$, yielding

\begin{equation}\frac{\partial }{\partial t} \int _{m_{0} }^{m_{\infty } }n(m,a) \partial m=g(m_{0} ,a) \; n(m_{0} ,a)-g(m_{\infty } ,a) \; n(m_{\infty } ,a)-\int _{m_{0} }^{m_{\infty } }d (m,a) \; n(m,a) \partial m.
\end{equation}

The LHS of this relationship is evidently the rate of change of total numbers of individual in the population, while the right-hand-term is the total population death rate. Further, $n(m_{\infty } ,a)=0$. Thus to balance total births and deaths, $g(m_{0} ,a) \; n(m_{0} ,a)$ must equal the birth rate $B(x, n, E,a)$. Thus the boundary condition is given by
\begin{equation}g(m_{0} ,a) \; n(m_{0} ,a)=B(x, n, E,a).
\end{equation}


# Converting density from one size unit to another

Population density is explicitly modelled in relation to a given size unit (Eq. $\ref{eq:PDE}$). But what if we want to express density in relation to another size unit? A relation between the two can be derived by noting that the total number of individuals within a given size range must be equal. So let's say density is expressed in units of size $m$, but we want density in units of size $h$. First we require a one-to-one function which h for a given $m$: $h = \hat{h}(m)$. Then the following must hold
\begin{equation} \label{eq:n_conversion} \int_{m_1}^{m_2} n(x,m,a) \; \textrm{d}m =  \int_{\hat{h}(m_1)}^{\hat{h}(m_2)} n^\prime(x,m,a) \; \textrm{d}h
\end{equation}

For very small size intervals, this equation is equivalent to
\begin{equation} \left(m_2- m_1 \right) \; n(x,m_1,a) = \left( \hat{h}(m_2) - \hat{h}(m_1)\right) \; n^\prime(x, \hat{h}(m_1),a).
\end{equation}

Rearranging gives
\begin{equation}  n^\prime(x, \hat{h}(m_1),a) = n(x, m_1,a) \; \frac{m_2- m_1}{\hat{h}(m_2) - \hat{h}(m_1)}
\end{equation}

Noting that the second term on the RHS is simply the definition of $\frac{\delta m}{\delta h}$ evaluated at $m_1$, we have
\begin{equation} \label{eq:n_conversion2} n^\prime(x, h, a) = n(x, m,a) \; \frac{\delta m}{\delta h}.
\end{equation}

