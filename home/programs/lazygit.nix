{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        # Catppuccin Mocha theme colors
        theme = {
          lightTheme = false;
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ]; # Blue
          inactiveBorderColor = [ "#45475a" ]; # Surface1
          optionsTextColor = [ "#cdd6f4" ]; # Text
          selectedLineBgColor = [ "#313244" ]; # Surface0
          selectedRangeBgColor = [ "#313244" ]; # Surface0
          cherryPickedCommitBgColor = [ "#94e2d5" ]; # Teal
          cherryPickedCommitFgColor = [ "#11111b" ]; # Crust
          unstagedChangesColor = [ "#f38ba8" ]; # Red
          defaultFgColor = [ "#cdd6f4" ]; # Text
        };
        # Better UI settings
        showIcons = true;
        showCommandLog = false;
        showBottomLine = true;
        showPanelJumps = true;
        showFileTree = true;
        showListFooter = true;
        showRandomTip = false;
        showBranchCommitHash = false;
        showFileIcons = true;
        commitLength = {
          show = true;
        };
        mouseEvents = true;
        skipDiscardChangeWarning = false;
        skipStashWarning = false;
        skipNoStagedFilesWarning = false;
        skipRewordInEditorWarning = false;
        border = "rounded";
        timeFormat = "02 Jan 06";
        shortTimeFormat = "3:04PM";
        authorColors = {
          "*" = "#b4befe"; # Lavender
        };
        branchColors = {
          "*" = "#a6e3a1"; # Green
        };
      };

      # Configure editor to open in new Ghostty terminal
      os = {
        editPreset = "";
        edit = "ghostty -e vim {{filename}}";
        editAtLine = "ghostty -e vim +{{line}} {{filename}}";
        editAtLineAndWait = "ghostty -e vim +{{line}} {{filename}}";
        open = "ghostty -e vim {{filename}}";
        openLink = "xdg-open {{link}}";
      };

      # Custom keybindings
      keybinding = {
        universal = {
          quit = "q";
          quitWithoutChangingDirectory = "Q";
          return = "<esc>";
          togglePanel = "<tab>";
          prevItem = "<up>";
          nextItem = "<down>";
          prevItem-alt = "k";
          nextItem-alt = "j";
          prevPage = ",";
          nextPage = ".";
          scrollLeft = "H";
          scrollRight = "L";
          gotoTop = "<";
          gotoBottom = ">";
          prevBlock = "<left>";
          nextBlock = "<right>";
          prevBlock-alt = "h";
          nextBlock-alt = "l";
          nextMatch = "n";
          prevMatch = "N";
          startSearch = "/";
          optionMenu = "<disabled>";
          optionMenu-alt1 = "?";
          select = "<space>";
          goInto = "<enter>";
          confirm = "<enter>";
          remove = "d";
          new = "n";
          edit = "e";
          openFile = "o";
          scrollUpMain = "<pgup>";
          scrollDownMain = "<pgdown>";
          scrollUpMain-alt1 = "K";
          scrollDownMain-alt1 = "J";
          scrollUpMain-alt2 = "<c-u>";
          scrollDownMain-alt2 = "<c-d>";
          executeShellCommand = ":";
          createRebaseOptionsMenu = "m";
          pushFiles = "P";
          pullFiles = "p";
          refresh = "R";
          createPatchOptionsMenu = "<c-p>";
          nextTab = "]";
          prevTab = "[";
          nextScreenMode = "+";
          prevScreenMode = "_";
          undo = "z";
          redo = "<c-z>";
          filteringMenu = "<c-s>";
          diffingMenu = "W";
          diffingMenu-alt = "<c-e>";
          copyToClipboard = "<c-o>";
          openRecentRepos = "<c-r>";
          submitEditorText = "<enter>";
          extrasMenu = "@";
          toggleWhitespaceInDiffView = "<c-w>";
          increaseContextInDiffView = "}";
          decreaseContextInDiffView = "{";
        };

        status = {
          checkForUpdate = "u";
          recentRepos = "<enter>";
          allBranchesLogGraph = "a";
        };

        files = {
          commitChanges = "c";
          commitChangesWithoutHook = "w";
          amendLastCommit = "A";
          commitChangesWithEditor = "C";
          confirmDiscard = "x";
          ignoreFile = "i";
          refreshFiles = "r";
          stashAllChanges = "s";
          viewStashOptions = "S";
          toggleStagedAll = "a";
          viewResetOptions = "D";
          fetch = "f";
          toggleTreeView = "`";
          openMergeTool = "M";
          openStatusFilter = "<c-b>";
        };

        branches = {
          createPullRequest = "o";
          viewPullRequestOptions = "O";
          copyPullRequestURL = "<c-y>";
          checkoutBranchByName = "c";
          forceCheckoutBranch = "F";
          rebaseBranch = "r";
          renameBranch = "R";
          mergeIntoCurrentBranch = "M";
          viewGitFlowOptions = "i";
          fastForward = "f";
          createTag = "T";
          pushTag = "P";
          setUpstream = "u";
          fetchRemote = "f";
        };

        commits = {
          squashDown = "s";
          renameCommit = "r";
          renameCommitWithEditor = "R";
          viewResetOptions = "g";
          markCommitAsFixup = "f";
          createFixupCommit = "F";
          squashAboveCommits = "S";
          moveDownCommit = "<c-j>";
          moveUpCommit = "<c-k>";
          amendToCommit = "A";
          pickCommit = "p";
          revertCommit = "t";
          cherryPickCopy = "C";
          pasteCommits = "V";
          tagCommit = "T";
          checkoutCommit = "<space>";
          resetCherryPick = "<c-R>";
          copyCommitMessageToClipboard = "<c-y>";
          openLogMenu = "<c-l>";
          viewBisectOptions = "b";
        };

        stash = {
          popStash = "g";
          renameStash = "r";
        };

        commitFiles = {
          checkoutCommitFile = "c";
        };

        main = {
          toggleSelectHunk = "a";
          pickBothHunks = "b";
          editSelectHunk = "E";
        };

        submodules = {
          init = "i";
          update = "u";
          bulkMenu = "b";
        };
      };

      # Git configuration
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        commit = {
          signOff = false;
        };
        merging = {
          manualCommit = false;
          args = "";
        };
        log = {
          order = "topo-order";
          showGraph = "when-maximised";
          showWholeGraph = false;
        };
        skipHookPrefix = "WIP";
        autoFetch = true;
        autoRefresh = true;
        branchLogCmd = "git log --graph --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --";
        allBranchesLogCmds = [
          "git log --graph --all --color=always --abbrev-commit --decorate --date=relative --pretty=medium"
        ];
        overrideGpg = false;
        disableForcePushing = false;
        parseEmoji = false;
        diffContextSize = 3;
      };

      # Update configuration
      update = {
        method = "prompt";
        days = 14;
      };

      # Refresh configuration
      refresher = {
        refreshInterval = 10;
        fetchInterval = 60;
      };

      # Confirmation settings
      confirmOnQuit = false;
      quitOnTopLevelReturn = false;

      # Disable mouse for better terminal experience
      disableStartupPopups = false;

      # Custom commands
      customCommands = [
        {
          key = "C";
          command = "git cz";
          description = "commit with commitizen";
          context = "files";
          loadingText = "opening commitizen commit tool";
          output = "terminal";
        }
        {
          key = "<c-p>";
          command = "git push --set-upstream origin $(git branch --show-current)";
          description = "push upstream";
          context = "localBranches";
          loadingText = "pushing branch upstream";
        }
      ];
    };
  };
}
