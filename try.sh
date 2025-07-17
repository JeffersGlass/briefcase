deactivate || 1
rm -rf .venv
rm -rf .tox
uv run --no-project python -m venv .venv
source .venv/bin/activate
python -m pip install -e .
python -m pip install -U --group dev
pre-commit install
#tox -e py
