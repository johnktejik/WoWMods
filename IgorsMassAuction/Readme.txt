I added a few lines of code to grab auctioneer prices.  see
http://wiki.norganna.org/Auctioneer/5.0/Core_API
- dax006 11/22/08

-------------------------------------------------------------------
Version 2.7.2 is a bug fix version to get Igor's Mass Auction working with WoW patch 3.0.2.  I am not the original author and take zero credit for this addon.  - Zirco (Oct 20, 08)

-------------------------------------------------------------------

Special Thanks to 
- Galvin for the Alt-click update.
- FireStriker for taking care of MassAuction while I was away!  He rocks!
- The Auctioneer team for updating their mod to work realy well with mine - I'm impressed!
- arberg for his patch

Igor's MassAuction v2.1 (20000)

Igor's MassAuction adds a MassAuction tab in the auction window.  This options allows you to post up to 18 auctions with one click.  Simply select all the items you wish to sell, set prices to your requirements, and press Submit. 

You can add items by Alt+clicking on them.

Once you submit, MassAuction will start placing up the auctions as fast as possible (very speedy).

This is a pre-final release, meaning that everything should work, but I want to put in maybe one or two more features, and see if any last bugs show up before 1.0

Igor's MassAuction is _heavily_ based on CT_MailMod - Thanks for a great mod!  You inspired me and helped me make this one!

Instructions:
1. Go to the Auction House and click on the MassAuction tab.
2. Alt+click on up to 18 items in your inventory you wish to sell.
3. Review prices and times and change as neccesary.
4. Click Submit, and confirm.
5. Auctions posted!

Features:
- Ability to place up to 18 auctions at once.
- Nice display that lets you see and set the prices and times of all 18 auctions at once.
- Compatability with EasyAuction so the last price you sold something for comes up automatically (EasyAuction required for this to work).
- Smart auction posting that posts as fast as possible in all conditions.
- Different pricing schemes:
  - Default      - uses whatever price that shows up like in the main Auctions tab (including modifications from other mods)
  - Multiplier   - set the Start Price to be a multiple of the Vendor Price, the Buyout to be a multiple of the Start Price, or both.
  - AllSamePrice - Set all items to be the same price, optionally taking into account the number of items.
  - EasyAuction  - Force using EasyAuction prices (the last price you posted that item for) Note: Requires EasyAuction mod
- You can see total deposit charge before posting anything (in dialog when you click Submit)
- Remembers the default duration you like to use for auctions

Upcoming features:
- Smart tab handling so you can set all prices with the keyboard
- Stack size support so you can sell a whole stack of items individually, or in pile sizes of your choice.  (Auctioneer does this, so try that if you need it in the meantime)
- *Insert your suggestion here*

Changelog:
2.1
- Fixed a bug where I was breaking stack splitting - changed all hooking to use the new securehookfunc.

2.0
- Updated toc to 20000
- Added support for Alt-click (tested in TBC beta works there too)

1.1
- Updated toc to 11100
- Added buttons so you can set every item to 2h, 8h, or 24h with one click (Thanks arberg! Sorry I took so long!)

1.0Beta
- Changed the toc to the current version of WoW.exe
- Modified the coding so that it will now work with Blizzard's new Load On Demand AH

0.9
- Consolidated settings into one variable
- IMA now remembers which duration you set for items and will always
come up as it was the previous use.
- Added pricing "Schemes" to give more control over setting prices
- Added Pingbo's code to make IMA work better with AuctionIt
- Added Sorny's code to the "Default" pricing scheme so default means it
will grab the price as it would be set by other existing mods
- upped interface version to 1600
- Fixed the item slot mouseover text

0.8.1beta
- Fixed a bug where dragging into MassAuction wasn't working

0.8beta
- Fixed bug where items with no deposit broke totalDeposit
- Fixed bug where totalDeposit wasn't getting updated when items are removed.
- MassAuction now clears when the auction house closes
- Added functionality to grey out items in bags when they are up for auction
- Fixed a bug where non-auctionable items got picked up when you Alt+clicked them
- Fixed a bug where you couldn't pick up an item after you pressed Clear
- Added support for enabling and disabling Submit and Clear buttons
- Sped up auction submissions so now they are super speedy and more reliable
- Added status while submitting
- Added ability to cancel while submitting
- Fixed a bug that caused a nil error in AuctionFrame.lua (ln 688/690)

0.7alpha
- Initial release
