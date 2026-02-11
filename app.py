from flask import Flask, request, jsonify
import time

app = Flask(__name__)

# Onde guardamos os players: { "UserID": tempo_do_ultimo_sinal }
players_online = {}

@app.route('/')
def index():
    return "Sistema de Contagem Online! Use /stats para ver."

@app.route('/ping', methods=['POST'])
def ping():
    # Recebe o sinal do script
    data = request.json
    user_id = str(data.get('user_id'))
    
    # Atualiza o horário que o player foi visto
    players_online[user_id] = time.time()
    
    return jsonify({"status": "recebido"})

@app.route('/stats', methods=['GET'])
def stats():
    agora = time.time()
    contagem = 0
    
    # Lista para deletar quem saiu (não deu sinal há 60 segundos)
    remover = []
    
    for uid, tempo in players_online.items():
        if agora - tempo < 60: # Se visto no último minuto
            contagem += 1
        else:
            remover.append(uid)
            
    # Limpa a memória
    for uid in remover:
        del players_online[uid]
        
    return jsonify({
        "online": contagem,
        "mensagem": f"Existem {contagem} usuarios usando o script agora."
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000)
