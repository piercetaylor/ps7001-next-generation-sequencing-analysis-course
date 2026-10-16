### Answer Deployments for PS4002/PS7001

## Scripts

There are 16 bash scripts, two for each of modules 1 through 8:

- `Module_X_Answer_Lab_Practice_deploy.sh` releases the lab and practice answers (`M{X}L{N}_Assignment_Name_A.ipynb`, `M{X}P{N}_Assignment_Name_A.ipynb`).
- `Module_X_Answer_Exercises_deploy.sh` releases the exercise answers (`M{X}E{N}_Assignment_Name_A.ipynb`).

Answers are read from `Development/answers/Module_X_Answers/`. Each answer is copied into the student's
matching folder, next to the original assignment:

| Prefix | Destination                          |
|--------|--------------------------------------|
| `M{X}L` | `Students/<student>/Module_X/Lab/`       |
| `M{X}P` | `Students/<student>/Module_X/Practice/`  |
| `M{X}E` | `Students/<student>/Module_X/Exercises/` |

Only top-level files ending in `_A.ipynb` are released. Anything else in the answers folder, such as `.ipynb_checkpoints`, is ignored.

## Running deployments

In a fresh terminal run the following commands:

`cd "$CLASS_DIR"`  (the root of the course directory)

`chmod +x Development/answers_deployment/Module_3_Answer_Lab_Practice_deploy.sh && bash Development/answers_deployment/Module_3_Answer_Lab_Practice_deploy.sh`

Each line of output is `DEPLOY` (copied) or `SKIP` (the student doesn't have the module yet, or already has that answer file).

## Notes

- Release the module itself (see `module_deployments/`) before releasing its answers. Students without the module are skipped.
- Existing answer files are never overwritten, so re-running a script is safe. Run it again to catch up students added late.
  To push a corrected answer key, delete the old `_A.ipynb` from the student folders first.
- Make sure only finished answer keys are in `Module_X_Answers/` before running. Every matching file is released.

-- Pierce Taylor
