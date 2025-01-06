# filtering-sequencer
- A multi where Falcon programs can be loaded and controlled by a sequencer script.
- The script is located on the master node so that multiple programs can be controlled at once.

- Sequencer Features:
  - Sequences are controlled by MIDI notes received by Falcon. The note played and held is considered the root note of the sequence.
  - Multiple notes can be held at once, however, this is not how the sequencer was intended to be used. Because of this, when multiple notes are held, new and unpredictable sequences occur. It can be interesting to experement with this.
  - The sequencer controls up to three effects located on the master node of the multi. The user can select a high pass filter, low pass filter, or reverb as effects.
  - The sequence has a maximum length of thirty two beats. Notes in the sequence have a maximum duration of two beats and a minimum duration of 1/4 beats.
  - For each note in the sequence, velocity, panning, offset from the root note, and bypass can be controled individually.
  - For each note in the sequence, the parameters of selected effects can be controlled individually (bypass, cutoff, resonance, etc.).
  - Changes can be made to multiple notes at once when multiple notes are selected. In this case, only the adjusted parameter is changed across all selected notes.
