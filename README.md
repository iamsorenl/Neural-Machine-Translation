# Neural-Machine-Translation

**Neural Machine Translation for French to English Using Fairseq**

This project explores neural machine translation (NMT) using the **IWSLT 2013 French-English dataset**, with an emphasis on the impact of **tokenization strategies** on model performance. Two core model architectures—**Transformer** and **CNN-based encoder-decoder**—are trained using the Fairseq framework. Experiments are conducted with and without **Byte Pair Encoding (BPE)** to compare vocabulary size, training dynamics, and translation quality.

**Key Goals:**
- Evaluate how **subword tokenization (BPE)** affects BLEU score and vocabulary size
- Compare BPE-based models to those using **whole word tokenization** via Moses
- Tune **hyperparameters** including dropout and encoder/decoder layer depth to optimize performance

**Notable Findings:**
- **Transformer without BPE** achieved the highest BLEU score of **28.98**, outperforming all BPE and CNN configurations
- BPE reduced vocabulary size substantially, helping models converge faster but sometimes at the cost of translation fluency
- Hyperparameter tuning (e.g., adjusting dropout from 0.3 to 0.2) yielded measurable improvements in translation quality

---

## Setting Up the Environment

To set up the virtual environment for this project, follow these steps:

1. **Create a virtual environment with Python 3.9:**
   ```bash
   python3.9 -m venv venv
   ```

2. **Activate the virtual environment:**
   - On macOS and Linux:
     ```bash
     source venv/bin/activate
     ```
   - On Windows:
     ```bash
     .\venv\Scripts\activate
     ```

3. **Upgrade to a compatible pip version:**
   ```bash
   pip install --upgrade pip==23.*
   ```

4. **Install the required packages:**
   ```bash
   pip install -r requirements.txt
   ```

5. **(Optional) Ensure shell scripts are executable:**
   ```bash
   chmod +x script_name.sh
   ```

> The project uses **Fairseq**, **SacreBLEU**, **Moses tokenizer**, and custom preprocessing scripts to tokenize, binarize, and train translation models. Make sure all relevant scripts and training configs are correctly linked in your experiment paths.

---
