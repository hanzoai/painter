# Hanzo Painter Documentation

This directory contains the documentation website for Hanzo Painter, built with Jekyll and deployed to GitHub Pages.

## Local Development

```bash
# Install dependencies
bundle install

# Run local server
bundle exec jekyll serve

# View at http://localhost:4000/painter/
```

## Structure

```
docs/
├── _config.yml           # Jekyll configuration
├── index.md              # Home page
├── quickstart.md         # Quick start guide
├── installation.md       # Installation instructions
├── usage.md              # Usage guide
├── troubleshooting.md    # Troubleshooting guide
└── Gemfile              # Ruby dependencies
```

## Deployment

Docs are automatically deployed to GitHub Pages when changes are pushed to `main` branch.

- **Live Site:** https://hanzoai.github.io/painter/
- **Auto-deployed:** On push to `docs/` or `.github/workflows/docs.yml`

## Theme

Using the Cayman theme from GitHub Pages.

Customize in `_config.yml`.
