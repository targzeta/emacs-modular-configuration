Emacs Modular Configuration
===========================

Emacs: making modular your config file.

Intro
-----

**Q.** What type of configuration do we prefer? It's better a very long singol file or many small files?<br />
**A.** Many small files for us and one (better if byte-compiled) very long file for emacs.

Emacs Modular Configuration lets you split your emacs configuration within of a (configurable) *`~/.config/emacs/emc/config`* directory. When you're ready, simply call **`emc-merge-config-files`** and all the `.el` files under that directory tree will merge on a (configurable) *`~/.emacs.d/emc/emc-config.el`*. Lastly, this file will be byte compiled, so all you need to write on your Emacs initalization file (e.g. *`~/.emacs` or `~/.emacs.d/init.el`*) is:

```lisp
    (load "~/.config/emacs/emc/emc-config")
```

**Note:** the directory tree *`~/.config/emacs/emc/config`* will be visited recursively using the [BFS algorithm](https://en.wikipedia.org/wiki/Breadth-first_search) and in alphabetical order.

Installation
------------

1. copy `emacs-modular-configuration.el` in a directory which is in the Emacs `load-path`
2. write on your Emacs initalization file (e.g. *`~/.emacs` or `~/.config/emacs/init.el`*):

```lisp
;; Emacs Modular Configuration entry point
(require 'emacs-modular-configuration)
(load "~/.config/emacs/emc/emc-config" t)
```

Usage
-----

1. write a bit of `.el` files within *`~/.config/emacs/emc/config`* directory tree
2. use **`emc-merge-config-files`**

Next time you start Emacs, you'll load the *`~/.config/emacs/emc/emc-config.elc`* file. That's all.

Customization
-------------

**`M-x customize-group`** and then **`modular-configuration`**.
