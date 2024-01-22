---
title: Markdown previewer utilizing pandoc
author: Civitasv
date: 2024-01-22
colorlinks: true
---

# mdp (**M**ark**d**own **P**reviewer)

> Live preview markdown using pdf viewer.

![showcase](images/showcase.png)

Now only support macOS.

## Requirements

- [pandoc](https://pandoc.org/)
- A pdf viewer, such as [Skim](https://skim-app.sourceforge.io/)

## Installation

```lua
{
    "Civitasv/mdp.nvim",
    config = function()
      require("mdp").setup(
        {
          pdfviewer = "Skim",
          template = "default"
        }
      )
    end
}
```

## Usage

Just call `:Mdp` in the markdown buffer.
