import tkinter as tk
from datetime import timedelta
import os

# Configurações de caminho
BASE_DIR = os.path.expanduser("~/_scripts/testbat")
FILE_PATH = os.path.join(BASE_DIR, "tempo_bateria.txt")

class BatteryTimer:
    def __init__(self, root):
        self.root = root
        self.root.title("Teste de Bateria")
        self.root.geometry("300x200")

        # Variáveis de controle
        self.running = False
        self.seconds = self.load_time()

        # Interface
        self.label = tk.Label(root, text=self.format_time(self.seconds), font=("Helvetica", 30))
        self.label.pack(pady=20)

        self.btn_start = tk.Button(root, text="START", command=self.start, width=10, bg="green", fg="white")
        self.btn_start.pack(side=tk.LEFT, padx=5, pady=10)

        self.btn_stop = tk.Button(root, text="STOP", command=self.stop, width=10, bg="red", fg="white")
        self.btn_stop.pack(side=tk.LEFT, padx=5, pady=10)

        self.btn_reset = tk.Button(root, text="RESET", command=self.reset, width=10, bg="gray", fg="white")
        self.btn_reset.pack(side=tk.LEFT, padx=5, pady=10)

        self.update_clock()

    def load_time(self):
        """Busca o tempo salvo no arquivo ou retorna 0 se não existir."""
        if os.path.exists(FILE_PATH):
            try:
                with open(FILE_PATH, "r") as f:
                    time_str = f.read().strip()
                    # Converte HH:MM:SS para segundos totais
                    h, m, s = map(int, time_str.split(':'))
                    return h * 3600 + m * 60 + s
            except:
                return 0
        return 0

    def save_time(self):
        """Salva o tempo formatado no arquivo .txt."""
        with open(FILE_PATH, "w") as f:
            f.write(self.format_time(self.seconds))

    def format_time(self, seconds):
        return str(timedelta(seconds=seconds)).zfill(8)

    def start(self):
        if not self.running:
            self.running = True

    def stop(self):
        self.running = False
        self.save_time() # Salva ao parar manualmente também

    def reset(self):
        self.running = False
        self.seconds = 0
        self.label.config(text=self.format_time(self.seconds))
        self.save_time()

    def update_clock(self):
        if self.running:
            self.seconds += 1
            self.label.config(text=self.format_time(self.seconds))
            
            # Salva no arquivo a cada 60 segundos (um minuto)
            if self.seconds % 60 == 0:
                self.save_time()
                
        # Agenda a próxima execução para 1 segundo depois
        self.root.after(1000, self.update_clock)

if __name__ == "__main__":
    # Garante que a pasta existe
    if not os.path.exists(BASE_DIR):
        os.makedirs(BASE_DIR)
        
    root = tk.Tk()
    app = BatteryTimer(root)
    root.mainloop()