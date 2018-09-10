# Tests for the Digital Asset Registry

## Restore tests

`docker build -t test_damc .`
`docker run test_damc python restore_check.py --prod_url 'https://hub.research.csiro.au/' --deploy_url 'https://hub-staging.research.csiro.au/' --max_gap_days 360 --max_gap_size 360`
