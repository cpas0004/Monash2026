from qiskit import QuantumCircuit 
from qiskit_aer import Aer 
from qiskit.visualization import plot_histogram 
import matplotlib.pyplot as plt 
qc = QuantumCircuit(2, 2) 
qc.cx(0, 1)
qc.h(0)
qc.measure([0,1], [0,1]) 
simulator = Aer.get_backend('aer_simulator') 
result = simulator.run(qc, shots=1000).result() 
counts = result.get_counts() 
print("CNOT first, then Hadamard:", counts) 
plot_histogram(counts) 
plt.show()