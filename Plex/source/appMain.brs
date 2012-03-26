' ********************************************************************
' **  Entry point for the Plex client. Configurable themes etc. haven't been yet.
' **
' ********************************************************************

Sub Main()
	' Development statements
	' RemoveAllServers()
	' AddServer("iMac", "http://192.168.1.3:32400")

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    showUpgradeMessage()

    'prepare the screen for display and get ready to begin
    controller = createViewController()
    controller.ShowHomeScreen()
End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "10"
    theme.OverhangSliceSD = "pkg:/images/Background_SD.jpg"
    theme.OverhangLogoSD  = "pkg:/images/logo_final_SD.png"

    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "10"
    theme.OverhangSliceHD = "pkg:/images/Background_HD.jpg"
    theme.OverhangLogoHD  = "pkg:/images/logo_final_HD.png"

    theme.GridScreenLogoOffsetHD_X = "125"
    theme.GridScreenLogoOffsetHD_Y = "10"
    theme.GridScreenOverhangSliceHD = "pkg:/images/Background_HD.jpg"
    theme.GridScreenLogoHD  = "pkg:/images/logo_final_HD.png"
    theme.GridScreenOverhangHeightHD = "99"

    theme.GridScreenLogoOffsetSD_X = "72"
    theme.GridScreenLogoOffsetSD_Y = "10"
    theme.GridScreenOverhangSliceSD = "pkg:/images/Background_SD.jpg"
    theme.GridScreenLogoSD  = "pkg:/images/logo_final_SD.png"
    theme.GridScreenOverhangHeightSD = "66"

    ' We want to use a dark background throughout, just like the default
    ' grid. Unfortunately that means we need to change all sorts of stuff.
    ' The general idea is that we have a small number of colors for text
    ' and try to set them appropriately for each screen type.

    background = "#363636"
    titleText = "#BFBFBF"
    normalText = "#999999"
    detailText = "#74777A"
    subtleText = "#525252"

    theme.BackgroundColor = background

    theme.GridScreenBackgroundColor = background
    theme.GridScreenRetrievingColor = subtleText
    theme.GridScreenListNameColor = titleText
    theme.CounterTextLeft = titleText
    theme.CounterSeparator = normalText
    theme.CounterTextRight = normalText
    ' Defaults for all GridScreenDescriptionXXX

    ' The actual focus border is set by the grid based on the style
    theme.GridScreenBorderOffsetHD = "(-9,-9)"
    theme.GridScreenBorderOffsetSD = "(-9,-9)"

    theme.ListScreenHeaderText = titleText
    theme.ListItemText = normalText
    theme.ListItemHighlightText = titleText
    theme.ListScreenDescriptionText = normalText

    theme.ParagraphHeaderText = titleText
    theme.ParagraphBodyText = normalText

    theme.ButtonNormalColor = normalText
    ' Default for ButtonHighlightColor seems OK...

    theme.RegistrationCodeColor = "#FFA500"
    theme.RegistrationFocalColor = normalText

    theme.SearchHeaderText = titleText
    theme.ButtonMenuHighlightText = titleText
    theme.ButtonMenuNormalText = titleText

    theme.PosterScreenLine1Text = titleText
    theme.PosterScreenLine2Text = normalText

    theme.SpringboardTitleText = titleText
    theme.SpringboardArtistColor = titleText
    theme.SpringboardArtistLabelColor = detailText
    theme.SpringboardAlbumColor = titleText
    theme.SpringboardAlbumLabelColor = detailText
    theme.SpringboardRuntimeColor = normalText
    theme.SpringboardActorColor = titleText
    theme.SpringboardDirectorColor = titleText
    theme.SpringboardDirectorLabel = detailText
    theme.SpringboardGenreColor = normalText
    theme.SpringboardSynopsisColor = normalText

    ' Not sure these are actually used, but they should probably be normal
    theme.SpringboardSynopsisText = normalText
    theme.EpisodeSynopsisText = normalText

    app.SetTheme(theme)

End Sub

Sub showUpgradeMessage()
    device = CreateObject("roDeviceInfo")
    version = device.GetVersion()
    major = Mid(version, 3, 1)
    minor = Mid(version, 5, 2)

    ' This shouldn't really exist in the wild...
    if major.toint() <= 3 AND minor.toint() < 1 then
        print "Can't upgrade, firmware 3.1 required"
        return
    end if

    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)
    screen.AddHeaderText("Plex for Roku in the Channel Store!")
    screen.AddParagraph("We're very excited to announce that Plex for Roku is now out of beta and available in the Channel Store (still free).")
    screen.AddParagraph("Thank you so much for helping us test this beta. We're always working on new things, and we'll let you know when we have another beta to play with. In the meantime, we'd prefer that you use the official channel, as that's where updates will be made.")
    screen.AddParagraph("Do you want to install the official channel now?")
    screen.AddButton(1, "Yes, please!")
    screen.AddButton(2, "No thanks")
    screen.Show()

    while true
        msg = wait(0, port)
        if type(msg) = "roParagraphScreenEvent"
            if msg.isScreenClosed() then
                exit while
            else if msg.isButtonPressed() then
                if msg.GetIndex() = 1 then
                    ' Really, no localhost support?
                    addrs = device.GetIPAddrs()
                    addrs.Reset()
                    if addrs.IsNext() then
                        addr = addrs[addrs.Next()]
                        ' TODO(schuyler): Use a real contentID once we have one.
                        http = NewHttp("http://" + addr + ":8060/launch/11?contentID=14")
                        http.PostFromStringWithTimeout("", 60)
                    end if
                else
                    screen.Close()
                end if
            end if
        end if
    end while
End Sub

