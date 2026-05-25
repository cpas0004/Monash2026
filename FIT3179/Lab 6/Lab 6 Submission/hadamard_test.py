from qiskit import QuantumCircuit 
from qiskit_aer import Aer 
qc = QuantumCircuit(1, 1) 
# Try without Hadamard first 
# qc.h(0)
qc.measure(0, 0) 
simulator = Aer.get_backend('aer_simulator') 
result = simulator.run(qc, shots=5000).result() 
print("Without Hadamard:", result.get_counts()) 

