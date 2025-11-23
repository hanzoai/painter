# Documentation

This directory contains the documentation for Hanzo Studio, automatically deployed to GitHub Pages.

## Structure

- `index.md` - Main documentation page
- `_config.yml` - Jekyll configuration for GitHub Pages

## Adding Documentation

1. Create new `.md` files in this directory
2. Link them from `index.md`
3. Commit and push to `master` branch
4. GitHub Actions will automatically build and deploy

## Local Preview

To preview locally with Jekyll:

```bash
cd docs
bundle exec jekyll serve
```

Visit http://localhost:4000

## Deployment

Documentation is automatically deployed to GitHub Pages when:
- Changes are pushed to `master` branch in the `docs/` directory
- The workflow is manually triggered

The site will be available at: https://hanzoai.github.io/Studio/
