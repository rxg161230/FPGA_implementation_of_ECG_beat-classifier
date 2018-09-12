# FPGA_implementation_of_ECG_beat-classifier
Testing of a MATLAB based ECG beat detector and classifier algorithm on a SPARTAN-6 FPGA to analyze hardware utilization, power and efficiency so as to ensure proper functioning of the algorithm in the form of a wearable device.
Software QRS detection has been popular for quite a while now, but testing these algorithms in real-world situations is still a challenge.
Here I am testing a modified version of the Pan-Tompkins algorithm on an FPGA .
The vhdl code is divided into two parts- pre-processing stage and decision making stage.
The algorithm revolves around the concept of finding the threshold based on previously detected peak values. The signgal is passed through a number of filters-lowpass, high pass, Derivative filter and Sqauring stage filter.
After which the signal is sent through a Finite State Machine which has the algorithm for the peak detection and then the result is stored in a memory, this peak detection takes places within a specific frame width, which keeps shifting.
