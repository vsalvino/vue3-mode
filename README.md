vue3-mode.el
============

Vue.js syntax highlighting for Emacs. Inspired by [vue-mode](https://github.com/AdamNiederer/vue-mode) with support for Vue 3 syntax, based on `polymode` which provides more accurate syntax highlighting and parsing.

Note: you should uninstall `vue-mode` if installing this package.

![image](https://github.com/vsalvino/vue3-mode/assets/13453401/b805432b-4943-4d9d-a81e-babb8a949df2)

Customizing
-----------

This mode does not have any customizations. However, polymode does have some behaviors that you may find annoying.

**Remove the subtle background highlighting from polymode** - add this to your `init.el`

```elisp
(defvar poly-lock-allow-fontification nil)
(defvar poly-lock-allow-background-adjustment nil)
```
