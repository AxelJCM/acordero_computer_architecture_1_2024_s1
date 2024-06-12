import tkinter as tk
from tkinter import ttk, messagebox
import matplotlib.pyplot as plt
import matplotlib
import os 

matplotlib.use('TkAgg')

class CPUConfigLogic:
    def __init__(self):
        self.cpu_type = "MinorCPU"
        
        self.cache_paths = {
            "MinorCPU": [
                "CPUs/MinorCPU/ARM/SPEC/CacheStats/stats2kB.txt",
                "CPUs/MinorCPU/ARM/SPEC/CacheStats/stats16kB.txt",
                "CPUs/MinorCPU/ARM/SPEC/CacheStats/stats64kB.txt",
                "CPUs/MinorCPU/ARM/SPEC/CacheStats/stats256kB.txt",
                "CPUs/MinorCPU/ARM/SPEC/CacheStats/stats1MB.txt"
            ],
            "O3CPU": [
                "CPUs/O3CPU/ARM/SPEC/CacheStats/stats2kB.txt",
                "CPUs/O3CPU/ARM/SPEC/CacheStats/stats16kB.txt",
                "CPUs/O3CPU/ARM/SPEC/CacheStats/stats64kB.txt",
                "CPUs/O3CPU/ARM/SPEC/CacheStats/stats256kB.txt",
                "CPUs/O3CPU/ARM/SPEC/CacheStats/stats1MB.txt"
            ]
        }

        self.replacement_paths = {
            "MinorCPU": [
                "CPUs/MinorCPU/ARM/SPEC/RPStats/stats_LRURP.txt",
                "CPUs/MinorCPU/ARM/SPEC/RPStats/stats_LFURP.txt",
                "CPUs/MinorCPU/ARM/SPEC/RPStats/stats_FIFORP.txt",
                "CPUs/MinorCPU/ARM/SPEC/RPStats/stats_MRURP.txt",
                "CPUs/MinorCPU/ARM/SPEC/RPStats/stats_RandomRP.txt"
            ],
            "O3CPU": [
                "CPUs/O3CPU/ARM/SPEC/RPStats/stats_LRURP.txt",
                "CPUs/O3CPU/ARM/SPEC/RPStats/stats_LFURP.txt",
                "CPUs/O3CPU/ARM/SPEC/RPStats/stats_FIFORP.txt",
                "CPUs/O3CPU/ARM/SPEC/RPStats/stats_MRURP.txt",
                "CPUs/O3CPU/ARM/SPEC/RPStats/stats_RandomRP.txt"
            ]
        }

        self.branch_paths = {
            "MinorCPU": [
                "CPUs/MinorCPU/ARM/SPEC/BPStats/stats_TournamentBP.txt",
                "CPUs/MinorCPU/ARM/SPEC/BPStats/stats_LocalBP.txt",
                "CPUs/MinorCPU/ARM/SPEC/BPStats/stats_TAGE.txt"
            ],
            "O3CPU": [
                "CPUs/O3CPU/ARM/SPEC/BPStats/stats_TournamentBP.txt",
                "CPUs/O3CPU/ARM/SPEC/BPStats/stats_LocalBP.txt",
                "CPUs/O3CPU/ARM/SPEC/BPStats/stats_TAGE.txt"
            ]
        }

    def read_stats_file(self, file_path):
        stats = {}
        try:
            with open(file_path, 'r') as file:
                for line in file:
                    if any(keyword in line for keyword in [
                        'overallMisses', 'overallHits', 'replacements', 
                        'branchPred.lookups', 'branchPred.condPredicted', 
                        'branchPred.condIncorrect', 'branchPred.BTBLookups', 
                        'branchPred.BTBUpdates', 'branchPred.BTBHits',
                        'dcache.overallMisses', 'icache.overallMisses',
                        'dcache.overallHits', 'icache.overallHits',
                        'cpu.cpi', 'cpu.ipc'
                    ]):
                        parts = line.split()
                        if len(parts) >= 2:
                            stat_name = parts[0]
                            stat_value = float(parts[1])
                            stats[stat_name] = stat_value
        except Exception as e:
            messagebox.showerror("Error", f"Error reading file: {e}")
        return stats

    def plot_stats(self, stats_list, labels, metrics, title):
        values = [[stats.get(metric, 0) for metric in metrics] for stats in stats_list]
        
        x = range(len(metrics))
        
        plt.figure(figsize=(10, 6))
        for i, val in enumerate(values):
            plt.bar([p + i * 0.2 for p in x], val, width=0.2, label=labels[i])
        
        plt.xticks([p + 0.2 for p in x], metrics, rotation='vertical')
        plt.ylabel('Value')
        plt.title(title)
        plt.legend()
        plt.tight_layout()
        plt.show()

    def on_play_button_click(self, checkboxes, label, arch_var):
        selected_arch = arch_var.get()
        selected_paths = []
        for var, path in checkboxes:
            modified_path = path.replace("RISCV", selected_arch).replace("ARM", selected_arch)
            if var.get() and os.path.exists(modified_path):
                selected_paths.append(modified_path)
        if selected_paths:
            stats_list = []
            for path in selected_paths:
                stats = self.read_stats_file(path)
                if stats:
                    stats_list.append(stats)
            if stats_list:
                section = label.cget('text')
                if section == "Replacement Policy:":
                    metrics = [
                        'system.l2.overallHits::total',
                        'system.l2.overallMisses::total',
                        'system.l2.replacements'
                    ]
                    self.plot_stats(stats_list, selected_paths, metrics, 'Comparison of Replacement Policy Stats')
                elif section == "Branch Predictor:":
                    metrics = [
                        'system.cpu.branchPred.lookups',
                        'system.cpu.branchPred.condPredicted',
                        'system.cpu.branchPred.condIncorrect',
                        'system.cpu.branchPred.BTBLookups',
                        'system.cpu.branchPred.BTBUpdates',
                        'system.cpu.branchPred.BTBHits'
                    ]
                    self.plot_stats(stats_list, selected_paths, metrics, 'Comparison of Branch Predictor Stats')
                elif section == "Cache Size:":
                    metrics1 = [
                        'system.cpu.dcache.overallHits::total',
                        'system.cpu.icache.overallHits::total'
                    ]
                    metrics2 = [
                        'system.cpu.cpi',
                        'system.cpu.ipc'
                    ]
                    self.plot_stats(stats_list, selected_paths, metrics1, 'Comparison of Cache Misses and Hits Stats')
                    self.plot_stats(stats_list, selected_paths, metrics2, 'Comparison of CPU Performance Stats')
            else:
                messagebox.showerror("Error", f"Failed to read stats from the selected files in {label.cget('text')}.")
        else:
            messagebox.showerror("Error", f"No valid files selected in {label.cget('text')}.")

    def update_paths(self, cpu_type):
        self.cpu_type = cpu_type

class CPUConfigGUI:
    def __init__(self, root, logic):
        self.root = root
        self.logic = logic

        self.root.title("Interfaz de Configuración de CPU")

        # Crear un Notebook (pestañas)
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(pady=10, expand=True)

        # Crear los frames para cada pestaña
        self.frame_minorcpu = ttk.Frame(self.notebook, width=600, height=400)
        self.frame_o3cpu = ttk.Frame(self.notebook, width=600, height=400)

        self.frame_minorcpu.pack(fill='both', expand=True)
        self.frame_o3cpu.pack(fill='both', expand=True)

        self.notebook.add(self.frame_minorcpu, text='MinorCPU')
        self.notebook.add(self.frame_o3cpu, text='O3CPU')

        # Añadir el dropdown (ARM o RISCV) a cada frame
        self.arch_minorcpu = self.add_dropdown(self.frame_minorcpu)
        self.arch_o3cpu = self.add_dropdown(self.frame_o3cpu)

        # Añadir secciones SPEC y PARSEC a cada frame
        self.add_spec_and_parsec_sections(self.frame_minorcpu, "MinorCPU", self.arch_minorcpu)
        self.add_spec_and_parsec_sections(self.frame_o3cpu, "O3CPU", self.arch_o3cpu)

        # Evento para cambiar de pestaña
        self.notebook.bind("<<NotebookTabChanged>>", self.on_tab_change)

    def on_tab_change(self, event):
        selected_tab = event.widget.tab(event.widget.index("current"))["text"]
        self.logic.update_paths(selected_tab)

    def add_dropdown(self, master):
        label = ttk.Label(master, text="Seleccionar arquitectura:", font=('Helvetica', 10, 'bold'))
        label.pack(pady=10)

        options = ["ARM", "RISCV"]
        selected_option = tk.StringVar(value=options[0])
        dropdown = ttk.OptionMenu(master, selected_option, *options)
        dropdown.pack(pady=5)

        def reset_options(*args):
            menu = dropdown['menu']
            menu.delete(0, 'end')
            for option in options:
                menu.add_command(label=option, command=tk._setit(selected_option, option))

        selected_option.trace('w', reset_options)
        return selected_option

    def create_checkbox_frame(self, master, text, values, paths, arch_var):
        frame = ttk.Frame(master)
        label = ttk.Label(frame, text=text, font=('Helvetica', 10, 'bold'))
        label.grid(row=0, column=0, sticky='w')

        checkboxes = []

        # Menubutton para los checkboxes
        menubutton = ttk.Menubutton(frame, text="Opciones", direction="below")
        menu = tk.Menu(menubutton, tearoff=0)

        for value, path in zip(values, paths):
            var = tk.BooleanVar()
            menu.add_checkbutton(label=value, variable=var)
            checkboxes.append((var, path))

        menubutton["menu"] = menu
        menubutton.grid(row=0, column=1, sticky='w')

        play_button = ttk.Button(frame, text="\u25B6", command=lambda: self.logic.on_play_button_click(checkboxes, label, arch_var))
        play_button.grid(row=0, column=2, padx=10)
        
        return frame, checkboxes

    def add_spec_and_parsec_sections(self, master, cpu_type, arch_var):
        logic = self.logic

        spec_label = ttk.Label(master, text="SPEC", font=('Helvetica', 12, 'bold'))
        spec_label.pack(pady=10)

        cache_frame, cache_checkboxes = self.create_checkbox_frame(
            master, "Cache Size:", ["4kB", "16kB", "64kB", "256kB", "1MB"], 
            [path.replace("MinorCPU", cpu_type) for path in logic.cache_paths[cpu_type]], arch_var
        )
        cache_frame.pack(pady=5)

        replacement_frame, replacement_checkboxes = self.create_checkbox_frame(
            master, "Replacement Policy:", ["LRURP", "LFURP", "FIFORP", "MRURP", "RandomRP"], 
            [path.replace("MinorCPU", cpu_type) for path in logic.replacement_paths[cpu_type]], arch_var
        )
        replacement_frame.pack(pady=5)

        branch_frame, branch_checkboxes = self.create_checkbox_frame(
            master, "Branch Predictor:", ["TournamentBP", "LocalBP", "TAGE"], 
            [path.replace("MinorCPU", cpu_type) for path in logic.branch_paths[cpu_type]], arch_var
        )
        branch_frame.pack(pady=5)

        parsec_label = ttk.Label(master, text="PARSEC", font=('Helvetica', 12, 'bold'))
        parsec_label.pack(pady=10)

        cache_parsec_frame, cache_parsec_checkboxes = self.create_checkbox_frame(
            master, "Cache Size:", ["2kB", "16kB", "64kB", "256kB", "1MB"], 
            [path.replace("SPEC", "PARSEC").replace("MinorCPU", cpu_type) for path in logic.cache_paths[cpu_type]], arch_var
        )
        cache_parsec_frame.pack(pady=5)

        replacement_parsec_frame, replacement_parsec_checkboxes = self.create_checkbox_frame(
            master, "Replacement Policy:", ["LRURP", "LFURP", "FIFORP", "MRURP", "RandomRP"], 
            [path.replace("SPEC", "PARSEC").replace("MinorCPU", cpu_type) for path in logic.replacement_paths[cpu_type]], arch_var
        )
        replacement_parsec_frame.pack(pady=5)

        branch_parsec_frame, branch_parsec_checkboxes = self.create_checkbox_frame(
            master, "Branch Predictor:", ["TournamentBP", "LocalBP", "TAGE"], 
            [path.replace("SPEC", "PARSEC").replace("MinorCPU", cpu_type) for path in logic.branch_paths[cpu_type]], arch_var
        )
        branch_parsec_frame.pack(pady=5)

# Crear la ventana principal
root = tk.Tk()
logic = CPUConfigLogic()
gui = CPUConfigGUI(root, logic)

# Ejecutar el bucle principal de la aplicación
root.mainloop()