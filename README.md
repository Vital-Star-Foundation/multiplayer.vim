# multiplayer.vim

This is a clone to [rolf007](https://github.com/rolf007/multiplayer.vim), original very well made vim collaborative edit plugin.  The changes made here is to accommodate the environment we are using.  These changes can be very well be adopted in the original plugin.

I have been researching collaborative editing plugin or tools using Vim.  None of those works for me except this one.  Due to lack of documentation, I need to twist a few things to get it to work in my environment.  There are still occassional hangs, but worth the effort to keep it working as collaborative editing is a key in our environment.  Hope my hacks could be of use to you. Also thank to [rolf007](https://github.com/rolf007/multiplayer.vim) for making this for Vim.

## Changes
1. [change pipe permission](https://github.com/rolf007/multiplayer.vim/issues/1): as described in this issue, the pipe creation in my environment stopping multi-users from collaborating due to pipe write permission issue.
2. It would be nice to have some doc to show how to use this great plugin.  This clone serves as a placeholder for me to capture my learning on how to use it.

## For Mac users
Since the plugin is using `sleep` internally, `sleep` in Mac works differntly than Linux.  Make sure you did the following.
```
brew install coreutils
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
```
This will allow gnu toolchain to be used before Mac provided version.  The culprit is `sleep infinity`.  It has no effect in Mac.

Hope this works for you too!
