# Course-operations tooling

Scripts the author wrote to run the course on a shared HPC file system. They
are included to show the course logistics. They contain **no** answer keys,
student data or grades.

| Folder | What it does |
|---|---|
| [`module_deployments/`](module_deployments/README.md) | `week_N_deploy.sh`: copies each week's module folder into every student folder. Never overwrites a module that has already been released |
| [`answers_deployment/`](answers_deployment/README.md) | `Module_X_Answer_*_deploy.sh`: releases answer notebooks (`*_A.ipynb`) to students after the due date. The answer keys are not in this repository |
| [`check_links.py`](check_links.py) | Checks that every relative link and image in the Markdown files and notebooks resolves, and that every file in `_toc.yml` exists (run in CI) |

The deployment scripts read the course root from the `CLASS_DIR`
environment variable:

```bash
export CLASS_DIR=/path/to/course/root     # contains Modules/, Students/, Development/
bash tools/module_deployments/week_1_deploy.sh
```
