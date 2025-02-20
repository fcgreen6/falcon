# **filtering-sequencer**


## **Description:**

- **Demo Video:** *Coming soon...*

- An experemental music sequencer created within the synthesizer UVI Falcon. The sequencer operates within the main node of Falcon's tree structure, allowing multiple instruments located on subsequent nodes to be controlled.

- Supports musical sequences up to thirty two beats in length. Beats can be consolodated and subdivided in order to create unique musical progressions.

- Each note of a sequence can be individually controled. Adjustable parameters include note on/off, transpose, panning (not compatable with certain instruments), velocity, and any added effect parameters.

  ![music sequencer image](demo-images/image1.png)


## **How to Run:**

- **Purchase UVI Falcon:** Purchase the synthesizer UVI Falcon (Available at: https://www.uvi.net/falcon.html).

- **Clone Repository:** Clone the falcon repository into a directory of your choice.

- **Set Up a MIDI Controller:** Connect UVI Falcon to a MIDI controller.

- **Load Sequencer Multi:** Navigate to the filtering-arpeggiator-template multi located within the cloned repository. Load the multi into UVI Falcon.

- **Add an Instrument to the Sequencer:** Using Falcon's tree visualizer as a reference, add an instrument to the "Part 1" node. To add more instrument to the sequence, create more parts.

  ![music sequencer image](demo-images/image2.png)


## **User Manual:**

- **Sequence Navigation and Selection Panel:**

  - **General Description:** The sequence navigation and selection pannel allows the user to efficiently move within a created sequence and select which notes they wish to modify.
 
      ![music sequencer image](demo-images/image3.png)

  - **Note Selection:** To select a note, simply click the desired note on the display. Selected notes will be displayed in blue. To deselect a note, click an already selected note on the display. Alternativley, the select all and deselect all buttons can be used to target all notes in the sequence.
 
  - **Arrow Buttons:** The arrow buttons, pictured to the left and right of the display panel, can be used to navigate to parts of the sequence that are not visible. This is due to the fact that the display panel only shows eight beats at a single time. The smaller arrow buttons move the display one beat in their respective direction. The larger arrow buttons move the display four beats in their respective direction.

- **Sequence Structure Pannel:**

  - **General Description:** The sequence structure pannel is used to arrange sequences in interesting ways through subdivision and consolodation.
 
    ![music sequencer image](demo-images/image4.png)


