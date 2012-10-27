{-# OPTIONS_GHC -tmpdir /tmp -optc -O2 -O2 #-}
import Control.Applicative
import Control.Concurrent
import Control.Monad
import Data.Maybe
import Data.Monoid
import System.Directory
import System.Exit
import System.FilePath
import System.Info
import XMonad
import XMonad.Actions.WindowGo
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ThreeColumns
import XMonad.Layout.FixedColumn
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.Run hiding (safeRunInTerm)
import XMonad.Layout.IndependentScreens
import XMonad.Actions.CycleWS

-- ==== CONFIG =================================================================
-- preferredTerminal
-- List is searched in-order. First terminal found to be installed is used as
-- default terminal. If no terminal from the list is found to be installed or
-- the list is empty, xterm is used.
preferredTerminal = ["gnome-terminal", "urxvt"]

-- menuBar
-- List is searched in-order. First menu bar to be found to be installed is
-- displayed. If no menu bar from the list is found to be installed or the list
-- is empty, no menu bar will be displayed.
menuBar = []

-- TODO
myBorderWidth = 2

-- normalBorderColor
-- the Color

-- ==== LOGIC ==================================================================

myNormalColour = "#202020"
myFocusedColour = "#ff0000"
myModMask = mod4Mask

myTerminal
    = myTerminal' preferredTerminal
    where
        myTerminal' []
            = findExecutable "xterm"
            >>= (return . fromJust)
        myTerminal' (t:ts)
            = findExecutable t
            >>=  maybe (myTerminal' ts) (return)


myStartupHook = do
    setWMName "XMonad-Raith"
    safeSpawn "xsetroot" ["-cursor_name", "left_ptr"]

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "gnome-panel"    --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen                  --> doFullFloat
    ]

myHandleEventHook = mempty
--myHandleEventHook = fullscreenEventHook

--myLogHook = return ()
myLogHook = takeTopFocus

myLayout = smartBorders $ avoidStruts $ layouts
    where
        layouts = tall
            ||| ThreeColMid 1 (3/100) (1/2)
            ||| Mirror tall
            ||| FixedColumn 1 20 80 10
            ||| (ThreeCol 1 (3/100) (1/3))
            ||| Grid
        tall = Tall 1 (3/100) (1/2)

{- Workspace Identifiers. Must correspond to keys in mkKeyMap format. -}
myWorkspaceNames = ((map (:"") "`1234567890-=")
             ++ ["<Esc>"]
             ++ ["<F"++x++">" | x <- (map show [1..12])])
myWorkspaces = withScreens 2 myWorkspaceNames

myKeys = do
    lock <- safeSpawnProg . fromMaybe "xlock" <$> findExecutable "slock"
    return $ \c -> mkKeymap c $
        [ ("M-S-<Return>",     safeSpawnProg $ XMonad.terminal c)
        , ("M-C-<Return>",     spawn "gnome-terminal --profile=NoScreen")
        , ("M-p",              safeSpawnProg "dmenu_run")
        , ("M-S-c",            kill)
        , ("M-<Space>",        sendMessage NextLayout)
        , ("M-S-<Space>",      setLayout $ XMonad.layoutHook c)
        , ("M-n",              refresh)
        , ("M-<Tab>",          windows W.focusDown)
        , ("M-j",              windows W.focusDown)
        , ("M-S-<Tab>",        windows W.focusUp)
        , ("M-k",              windows W.focusUp)
        , ("M-m",              windows W.focusMaster)
        , ("M-<Return>",       windows W.swapMaster)
        , ("M-S-j",            windows W.swapDown)
        , ("M-S-k",            windows W.swapUp)
        , ("M-h",              sendMessage Shrink)
        , ("M-l",              sendMessage Expand)
        , ("M-t",              withFocused $ windows . W.sink)
        , ("M-,",              sendMessage (IncMasterN 1))
        , ("M-.",              sendMessage (IncMasterN (-1)))
        --, ("M-S-q",            shutdownHook >> io exitSuccess)
        {- Recompile if necessary. Unless the compiler gave errors,
         - run shutdownHook and restart -}
        , ("M-q",              do
                                   b <- recompile False
                                   when b $
                                       restartHook
                                       >> shutdownHook
                                       >> safeSpawn "xmonad" ["--restart"] )
        , ("M-a",              safeRunInTerm "alsamixer" [])
        , ("M-<Right>", nextWS)
        {- Power off screen -}
        , ("M-S-s",            screenOff)
        {- Take a screenshot, save as 'screenshot.png' -}
        , ("M-<Print>",        safeSpawn "import" [ "-window", "root"
                                                  , "screenshot.png" ])
        , ("<XF86Eject>",      safeSpawn "eject" ["-T"])
        , ("<XF86Sleep>",      lock >> sleep 1
                               >> safeSpawn "sudo" ["pm-hibernate"])
        , ("<XF86Calculator>", safeSpawnProg "speedcrunch")
        , ("<XF86Search>",     xmessage "search")
        , ("<XF86Mail>",       xmessage "mail")
        , ("<XF86WebCam>",     xmessage "smile")
        ] ++
        {- Workspace Switching -}
        [ (m ++ k, windows $ onCurrentScreen f k)
              | k <- workspaces' c
              , (f, m) <- [(W.greedyView, "M-"), (W.shift, "M-S-")]
        ] ++
        {- Screen Switching -}
        [ (m ++ key, screenWorkspace sc >>= flip whenJust (windows . f))
              | (key, sc) <- zip ["w", "e", "r"] [0..]
              , (m, f) <- [("M-", W.view), ("M-S-", W.shift)]
        ] -- ++
        {- Spawning Firefox -}
        {-[ ( k, runOrRaise "firefox" (className =? "Firefox"))
            | k <- ["M-f", "<XF86HomePage>"]
        ] ++-}
        {- Screen Locking -}
        {-[ (k , lock >> screenOff)
            | k <- ["M-x", "<XF86ScreenSaver>"]
        ]-}
    where
        safeRunInTerm c o =
            asks (terminal . config) >>= flip safeSpawn (["-e", c] ++ o)
        sleep = io . threadDelay . seconds
        screenOff = sleep 1 >> safeSpawn "xset" ["dpms", "force", "off"]
        -- TODO only strip on recompile
        restartHook = do
            d <- io (getAppUserDataDirectory "xmonad")
            safeSpawn "strip" [ "--strip-unneeded"
                              , d </> "xmonad-" ++ arch ++ "-" ++ os ]
        shutdownHook = safeSpawn "killall" ["trayer"]
        xmessage = safeSpawn "xmessage" . (:[])

myConfig = do
    t <- myTerminal
    -- let t = myTerminal
    k <- myKeys
    return defaultConfig
        { normalBorderColor  = myNormalColour
        , focusedBorderColor = myFocusedColour
        , borderWidth        = myBorderWidth
        , focusFollowsMouse  = False
        , modMask            = myModMask
        , terminal           = t
        , startupHook        = myStartupHook
        , manageHook         = myManageHook
        , handleEventHook    = myHandleEventHook
        , logHook            = myLogHook
        , layoutHook         = myLayout
        , workspaces         = myWorkspaces
        , keys               = k
        }

main = do
           myConfig >>= xmonad
