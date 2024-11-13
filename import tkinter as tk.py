import tkinter as tk
from tkinter import messagebox
import sqlite3

conn = sqlite3.connect('database.db')
cursor = conn.cursor()

def create_tables():
    cursor.execute('''CREATE TABLE IF NOT EXISTS Cargo (
        descricao_cargo TEXT,
        cod_cargo INTEGER PRIMARY KEY
    )''')
    
    cursor.execute('''CREATE TABLE IF NOT EXISTS Pessoa (
        nome_pessoa TEXT,
        cpf TEXT PRIMARY KEY,
        fk_Cargo_cod_cargo INTEGER,
        FOREIGN KEY (fk_Cargo_cod_cargo) REFERENCES Cargo (cod_cargo) ON DELETE CASCADE
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Planta (
        especie TEXT,
        nome_planta TEXT,
        nome_cientifico TEXT,
        cuidados TEXT,
        grupo TEXT,
        cod_planta INTEGER PRIMARY KEY
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Mapa (
        area TEXT,
        icone TEXT,
        fk_Pessoa_cpf TEXT,
        fk_Planta_cod_planta INTEGER,
        FOREIGN KEY (fk_Pessoa_cpf) REFERENCES Pessoa (cpf) ON DELETE CASCADE,
        FOREIGN KEY (fk_Planta_cod_planta) REFERENCES Planta (cod_planta) ON DELETE CASCADE
    )''')
    conn.commit()

def create_cargo(descricao, codigo):
    cursor.execute("INSERT INTO Cargo (descricao_cargo, cod_cargo) VALUES (?, ?)", (descricao, codigo))
    conn.commit()

def read_cargos():
    cursor.execute("SELECT * FROM Cargo")
    return cursor.fetchall()

def update_cargo(cod_cargo, nova_descricao):
    cursor.execute("UPDATE Cargo SET descricao_cargo = ? WHERE cod_cargo = ?", (nova_descricao, cod_cargo))
    conn.commit()

def delete_cargo(cod_cargo):
    cursor.execute("DELETE FROM Cargo WHERE cod_cargo = ?", (cod_cargo,))
    conn.commit()

def cargo_interface():
    def adicionar_cargo():
        descricao = descricao_entry.get()
        codigo = codigo_entry.get()
        if descricao and codigo:
            try:
                create_cargo(descricao, int(codigo))
                messagebox.showinfo("Sucesso", "Cargo adicionado com sucesso!")
                atualizar_lista_cargos()
            except sqlite3.IntegrityError:
                messagebox.showerror("Erro", "Código já existente!")
        else:
            messagebox.showerror("Erro", "Preencha todos os campos!")

    def atualizar_lista_cargos():
        cargos_listbox.delete(0, tk.END)
        for cargo in read_cargos():
            cargos_listbox.insert(tk.END, f"ID: {cargo[1]} - Descrição: {cargo[0]}")

    def atualizar_cargo():
        selecionado = cargos_listbox.curselection()
        if selecionado:
            codigo = int(codigo_entry.get())
            nova_descricao = descricao_entry.get()
            update_cargo(codigo, nova_descricao)
            messagebox.showinfo("Sucesso", "Cargo atualizado com sucesso!")
            atualizar_lista_cargos()
        else:
            messagebox.showerror("Erro", "Selecione um cargo para atualizar.")

    def deletar_cargo():
        selecionado = cargos_listbox.curselection()
        if selecionado:
            cargo_text = cargos_listbox.get(selecionado)
            cod_cargo = int(cargo_text.split("ID: ")[1].split(" -")[0])
            delete_cargo(cod_cargo)
            messagebox.showinfo("Sucesso", "Cargo deletado com sucesso!")
            atualizar_lista_cargos()
        else:
            messagebox.showerror("Erro", "Selecione um cargo para deletar.")

    janela = tk.Tk()
    janela.title("Gerenciamento de Cargos")
    janela.geometry("400x400")

    tk.Label(janela, text="Descrição do Cargo").pack()
    descricao_entry = tk.Entry(janela)
    descricao_entry.pack()

    tk.Label(janela, text="Código do Cargo").pack()
    codigo_entry = tk.Entry(janela)
    codigo_entry.pack()

    tk.Button(janela, text="Adicionar Cargo", command=adicionar_cargo).pack(pady=5)
    tk.Button(janela, text="Atualizar Cargo", command=atualizar_cargo).pack(pady=5)
    tk.Button(janela, text="Deletar Cargo", command=deletar_cargo).pack(pady=5)

    cargos_listbox = tk.Listbox(janela, width=50, height=10)
    cargos_listbox.pack(pady=10)
    atualizar_lista_cargos()

    janela.mainloop()

create_tables()  
cargo_interface()

conn.close()
