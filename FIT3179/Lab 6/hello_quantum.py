from qiskit import QuantumCircuit 
from qiskit_aer import Aer 
from qiskit.visualization import plot_histogram 
import matplotlib.pyplot as plt 
qc = QuantumCircuit(1, 1) 
qc.h(0) 
qc.measure(0, 0) 
simulator = Aer.get_backend('aer_simulator') 
result = simulator.run(qc, shots=10000).result() 
counts = result.get_counts() 
print(counts) 
plot_histogram(counts) 
plt.show() 