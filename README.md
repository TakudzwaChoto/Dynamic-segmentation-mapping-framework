# Dynamic Segmentation Mapping (DSM) Framework for Water Quality Management
This project implements a **Water Quality Management System** using EVM-compatible blockchain (Sepolia testnet) with Dynamic Segmentation Mapping (DSM) to achieve efficient, scalable, and cost-effective data management.
---

## 📁 Project Structure
```bash
├── contracts/
│   ├── OptimizedContract.sol
│   ├── UnoptimizedContract.sol
│   └── WaterQualityData.sol
├── client-ui/
├── server-api/
├── test/
├── scripts/
├── Makefile
└── foundry.toml
```
---

## ⚙️ Prerequisites
| Requirement     | Purpose                        | Installation |
|----------------|--------------------------------|-------------|
| Node.js & npm  | API server and client UI       | https://nodejs.org/en/download/ |
| Git            | Version control                | https://git-scm.com/book/en/v2/Getting-Started-Installing-Git |
| Foundry        | Solidity compilation & testing | `curl -L https://foundry.paradigm.xyz \| bash` |
| Python 3.11+   | Gas benchmarking & ML          | `pip install -r requirements.txt` |

---
## 💻 System Requirements
| Component         | Minimum                          | Recommended |
|------------------|----------------------------------|------------|
| Operating System | Linux, macOS, Windows 11 (WSL2)  | Same       |
| Memory           | 8GB RAM                          | 16–32GB    |
| Disk Space       | 10GB                             | 50GB       |
---

## 🚀 Quick Start
### 1. Clone the Repository

```bash
git clone git@github.com:TakudzwaChoto/Dynamic-segmentation-mapping-framework.git
cd Dynamic-segmentation-mapping-framework
```

### 2. Build Smart Contracts
```bash
make build
```

### 3. Run Tests
```bash
make test
make test-verbose
```

### 4. Run Gas Benchmark
```bash
python3 scripts/gas_benchmark.py
```

### 5. Train ML Model
```bash
python3 scripts/predictive_segmentation.py
```
---

## 📦 Deployment
### Deploy Smart Contract
```bash
forge create contracts/OptimizedContract.sol:OptimizedContract \
  --rpc-url sepolia \
  --private-key YOUR_PRIVATE_KEY
```
## 📊 Key Results
| Metric                | Optimized | Unoptimized | Improvement |
|----------------------|----------|-------------|------------|
| Deployment Gas       | 532,813  | 607,182     | 12.2%      |
| Execution Time       | 0.11 s   | 0.17 s      | 35.3%      |
| Complexity           | O(n)     | O(n²)       | Massive    |
---

## 🌐 UI Deployment
- UI live application: https://water-quality-resource-management.surge.sh/
- Smart Contract: https://eth-sepolia.blockscout.com/
### User Interface (UI)
The UI is built with **HTML5 and React** and deployed on **Surge**:
The frontend connects directly to **Remix IDE** for smart contract interaction. Users can:
- Connect MetaMask to Sepolia testnet
- Interact with the deployed DSM smart contract
- Report, transact, and visualize water quality data
- View gas consumption comparisons
---

## ✨ Key Features
- Smart Contract Deployment on Sepolia Testnet  
- Dynamic Segmentation Mapping (DSM)  
- Predictive ML Segmentation (Random Forest, 89.7% accuracy)  
- Chainlink Oracle Integration  
- React + HTML5 UI  
- Statistical validation (50 runs, p < 0.001)
---

## 📸 Screenshots
### Desktop
![Desktop](https://github.com/user-attachments/assets/8368603e-68b4-4701-b98f-290294302bf1)

### Wallet Connection
![Wallet](https://github.com/user-attachments/assets/8abff186-c538-462d-9918-ee99cf10b779)

### Mobile
![Mobile1](https://github.com/user-attachments/assets/8ff90e0d-36b1-4fb2-a732-12df84bfb512)
![Mobile2](https://github.com/user-attachments/assets/cc4ee75b-f2e6-4708-9568-6cdf538cad06)
![Mobile3](https://github.com/user-attachments/assets/e64faf37-532a-4b8f-ab4b-92236bd2e5e9)
---

## 🤖 Predictive ML Results
| Metric   | Value |
|----------|------|
| Accuracy | 89.7% (95% CI: [88.6%, 90.8%]) |
---

## 📌 Summary
This project demonstrates how **blockchain + optimization + machine learning** can be combined to build a scalable and efficient water quality management system.
