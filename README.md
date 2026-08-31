⚠️ **WORK IN PROGRESS** ⚠️

I'm only pushing this now as backup.



### About



sumi\_dnd is a specialized Canva PDF parser and search interface layer for Realms Unknown.



### dm/



**dm\_pdf** requires files in this directory to function. These are large PDF files which is why I've excluded them from the repo. Will be publicly uploading my PDFs soon. Until then, these assets will be missing for other users, if any.



### dm\_pdf.py



**Known fatal assumptions**



1. All class cards have a copy of the same rectangular image behind them.
2. All cards follow the same set of known markers in the text (see code).
3. All comments are a mid gray and italic.
4. Subheaders in the skill card are always bold and are always the only bold text in the skill card.
5. Skill cards are split vertically at the subheader that says "Passive".
6. Stat cards follow this order of data:

   * Main stats
   * Sub stats
   * Bonus attributes
7. The source PDF uses a DeviceRGB color space.



Basically, the program assumes that all class cards look as seen in **dm/class\_template.pdf**.



### Credits



Tristan Bonaobra (Author)

Zedryck Pugayan (Assets)

