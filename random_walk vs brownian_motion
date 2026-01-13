import numpy as np
import matplotlib.pyplot as plt
import os

def simulate_donsker(N=250, M=5, T=1.0, seed=123):
    """
    Simulates Scaled Random Walks and Brownian Motion to demonstrate Donsker's Theorem.
    """
    np.random.seed(seed)
    dt = T / N
    t = np.linspace(0, T, N + 1)

    plt.figure(figsize=(12, 8))

    # 1. Scaled Random Walk
    plt.subplot(2, 2, 1)
    for _ in range(M):
        xi = 2 * (np.random.rand(N) > 0.5) - 1  # Bernoulli +/- 1
        S = np.concatenate(([0], np.cumsum(xi))) / np.sqrt(N)
        plt.step(t, S, linewidth=1.1, where='mid')
    plt.title('Scaled Random Walk (Discrete)')
    plt.grid(True, alpha=0.3)
    plt.ylabel('Position')

    # 2. Brownian Motion
    plt.subplot(2, 2, 3)
    for _ in range(M):
        dW = np.sqrt(dt) * np.random.randn(N)
        W = np.concatenate(([0], np.cumsum(dW)))
        plt.plot(t, W, linewidth=1.1)
    plt.title('Brownian Motion (Continuous)')
    plt.grid(True, alpha=0.3)
    plt.xlabel('Time (t)')
    plt.ylabel('Value')

    # 3. Comparison
    plt.subplot(1, 2, 2)
    # Generate distinct samples
    xi_sample = 2 * (np.random.rand(N) > 0.5) - 1
    S_sample = np.concatenate(([0], np.cumsum(xi_sample))) / np.sqrt(N)
    
    dW_sample = np.sqrt(dt) * np.random.randn(N)
    W_sample = np.concatenate(([0], np.cumsum(dW_sample)))

    plt.step(t, S_sample, 'r', label='Scaled RW', linewidth=1.5, where='mid')
    plt.plot(t, W_sample, 'b', label='Brownian Motion', linewidth=1.5, alpha=0.7)
    plt.legend()
    plt.title('Trajectory Comparison')
    plt.grid(True, alpha=0.3)

    plt.suptitle(r"Donsker's Theorem: RW $\to$ Brownian Motion", fontsize=16)
    plt.tight_layout()
    
    # Save safely
    filename = 'donsker_convergence.pdf'
    plt.savefig(filename)
    print(f"Figure saved to {os.getcwd()}/{filename}")
    plt.show()

if __name__ == "__main__":
    simulate_donsker()
