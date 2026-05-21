import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import threading

class SnakemakeGUI(tk.Tk):
    def __init__(self):
        super().__init__()

        # Window settings
        self.title("Snakemake Pipeline GUI")
        self.geometry("600x500")

        # File selection label and button
        self.snakefile_label = tk.Label(self, text="Select Snakefile:")
        self.snakefile_label.pack(pady=10)

        self.snakefile_entry = tk.Entry(self, width=50)
        self.snakefile_entry.pack(pady=5)

        self.select_button = tk.Button(self, text="Browse", command=self.select_snakefile)
        self.select_button.pack(pady=5)

        # Snakemake parameters
        self.create_parameters_menu()

        # Run button
        self.run_button = tk.Button(self, text="Run Snakemake", command=self.run_snakemake)
        self.run_button.pack(pady=10)

        # Text area to display Snakemake output
        self.output_text = tk.Text(self, height=15, width=80)
        self.output_text.pack(pady=10)

        # Progress label
        self.progress_label = tk.Label(self, text="")
        self.progress_label.pack(pady=5)

    def create_parameters_menu(self):
        """Create the menu for setting Snakemake parameters."""

        # Label for parameters section
        self.param_label = tk.Label(self, text="Snakemake Parameters:")
        self.param_label.pack(pady=10)

        # Custom parameters entry box
        self.custom_params_label = tk.Label(self, text="Additional Snakemake Parameters:")
        self.custom_params_label.pack(pady=5)

        self.custom_params_entry = tk.Entry(self, width=50)
        self.custom_params_entry.pack(pady=5)

    def select_snakefile(self):
        """Open a file dialog to select the Snakefile."""
        snakefile_path = filedialog.askopenfilename(
            title="Select Snakefile",
            filetypes=(("Snakefile", "*.smk"), ("All Files", "**"))
        )
        if snakefile_path:
            self.snakefile_entry.delete(0, tk.END)
            self.snakefile_entry.insert(0, snakefile_path)

    def run_snakemake(self):
        """Run Snakemake in a background thread to avoid freezing the GUI."""
        snakefile_path = self.snakefile_entry.get()

        if not snakefile_path:
            messagebox.showerror("Error", "Please select a Snakefile!")
            return

        # Collect Snakemake parameters from the user interface
        snakemake_cmd = self.construct_snakemake_command(snakefile_path)

        # Start Snakemake in a separate thread to keep the UI responsive
        threading.Thread(target=self._run_snakemake_process, args=(snakemake_cmd,)).start()

    def construct_snakemake_command(self, snakefile_path):
        """Construct the Snakemake command based on selected parameters."""
        command = ["snakemake", "--snakefile", snakefile_path]

        # Add any additional custom parameters
        custom_params = self.custom_params_entry.get()
        if custom_params:
            command.extend(custom_params.split())

        return command

    def _run_snakemake_process(self, snakemake_cmd):
        """Run the Snakemake process and display its output."""
        try:
            self.progress_label.config(text="Running Snakemake...")

            # Running Snakemake command
            process = subprocess.Popen(
                snakemake_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            )

            # Read output line by line and append to the text area
            for stdout_line in iter(process.stdout.readline, ""):
                self.output_text.insert(tk.END, stdout_line)
                self.output_text.see(tk.END)  # Scroll to the bottom

            process.stdout.close()
            process.wait()

            # Handle errors (if any)
            if process.returncode != 0:
                error_message = process.stderr.read()
                self.output_text.insert(tk.END, f"Error: {error_message}\n")
                self.output_text.see(tk.END)
            else:
                self.output_text.insert(tk.END, "Snakemake completed successfully.\n")
                self.output_text.see(tk.END)

        except Exception as e:
            messagebox.showerror("Error", f"An error occurred while running Snakemake: {e}")
        finally:
            self.progress_label.config(text="")

if __name__ == "__main__":
    app = SnakemakeGUI()
    app.mainloop()