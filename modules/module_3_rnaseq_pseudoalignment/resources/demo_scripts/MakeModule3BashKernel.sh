#!/bin/bash

ml mamba
CONDA_BASE="$(conda info --base)"   # your miniconda/mamba install prefix
source activate Module_3_Local_Env
# Install the Bash kernel into this environment
python -m bash_kernel.install --sys-prefix

# Set kernel directory
KERNEL_DIR="$CONDA_PREFIX/share/jupyter/kernels/bash"

# Check if kernel.json exists
if [[ -f "$KERNEL_DIR/kernel.json" ]]; then
  echo "Updating kernel.json to activate Module_3_Local_Env automatically..."
  
  # Overwrite kernel.json with a robust configuration
  cat > "$KERNEL_DIR/kernel.json" <<EOL
{
  "argv": [
    "/bin/bash",
    "-c",
    "source ${CONDA_BASE}/etc/profile.d/conda.sh && conda activate Module_3_Local_Env && exec python -m bash_kernel -f {connection_file}"
  ],
  "display_name": "Module 3 - Bash",
  "language": "bash",
  "codemirror_mode": "shell"
}
EOL

  echo "kernel.json updated successfully."
else
  echo "Could not find kernel.json in $KERNEL_DIR"
fi