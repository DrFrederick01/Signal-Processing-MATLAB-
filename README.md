# 📈 Swallowing Sound Signal Analysis (MATLAB)

This coursework project for the **Signals and Systems (5CCE2SAS)** module focused on recording and analysing swallowing sounds using digital signal processing techniques in MATLAB. The objective was to study the differences between swallowing water and swallowing food by comparing provided datasets with our own recorded signals.  

---

## Objective

To design and implement a reproducible data analysis workflow for swallowing sounds, including:  
- Time-domain visualisation of signals  
- Quantification of signal size and signal-to-noise ratio (SNR)  
- Frequency-domain analysis using FFTs  
- Estimation of essential bandwidths of swallowing events  
- Investigation of how downsampling affects SNR and bandwidth  
- Comparison between provided dataset (dataset_1) and recorded dataset (dataset_2)  

---

## Tech Stack

- **MATLAB** (signal processing & analysis)  
- **Mobile recording devices** (for dataset_2 collection)  
- **IEEE conference paper format** for final report  

---

## Methodology

1. **Data Collection**  
   - Analysed dataset_1 containing 5 samples of water swallowing and 5 samples of food swallowing.  
   - Recorded dataset_2 with 5 new samples of swallowing sounds using mobile devices.  
   - Selected one category (water or food) for consistent comparison.  

2. **Signal Analysis Steps**  
   - Time-domain inspection of raw audio waveforms.  
   - SNR calculation before and after downsampling.  
   - FFT analysis to extract frequency spectra.  
   - Estimation of essential bandwidth for swallowing events.  
   - Comparison between dataset_1 and dataset_2 using descriptive statistics.  

3. **Outputs**  
   - Graphs of time-domain signals and spectra.  
   - Tables of SNR values, bandwidths, and statistical comparisons.  
   - Final written report in IEEE format.  

---

## Challenges Encountered

- Ensuring consistency between recordings across different devices.  
- Maintaining reproducibility of downsampling effects while avoiding aliasing.  
- Handling noise contamination in real-world swallowing recordings.  
- Balancing accuracy of SNR calculation with computational efficiency.  

---

## Outcomes

- Successfully quantified differences in SNR and bandwidth between water and food swallowing.  
- Demonstrated the impact of downsampling on signal clarity and frequency content.  
- Produced reproducible MATLAB scripts capable of generating all figures in the report.  
- Final report structured in IEEE format, meeting the coursework requirements.  


