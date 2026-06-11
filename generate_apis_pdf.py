from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_fill_color(34, 139, 34)
        self.rect(0, 0, 210, 18, 'F')
        self.set_font('Helvetica', 'B', 14)
        self.set_text_color(255, 255, 255)
        self.set_y(4)
        self.cell(0, 10, 'EcoScan - APIs Utilisees', align='C')
        self.set_text_color(0, 0, 0)
        self.ln(14)

    def footer(self):
        self.set_y(-12)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(150, 150, 150)
        self.cell(0, 10, f'Page {self.page_no()}', align='C')


pdf = PDF()
pdf.add_page()
pdf.set_auto_page_break(auto=True, margin=15)

# ── Section 1 ────────────────────────────────────────────────────────────────
pdf.set_font('Helvetica', 'B', 13)
pdf.set_text_color(34, 139, 34)
pdf.cell(0, 8, 'APIs Externes', ln=True)
pdf.set_text_color(0, 0, 0)
pdf.ln(2)

# Table header
COL = [10, 45, 80, 55]   # widths: #, Service, URL, Usage
HEADER_BG = (34, 139, 34)
ROW_BG1   = (240, 248, 240)
ROW_BG2   = (255, 255, 255)

def draw_row(pdf, cols, data, bg, bold=False):
    pdf.set_fill_color(*bg)
    pdf.set_font('Helvetica', 'B' if bold else '', 9)
    h = 8
    x0 = pdf.get_x()
    y0 = pdf.get_y()
    for w, txt in zip(cols, data):
        pdf.set_xy(x0, y0)
        pdf.cell(w, h, txt, border=1, fill=True)
        x0 += w
    pdf.ln(h)

headers = ['#', 'Service', 'URL de base', 'Usage']
pdf.set_text_color(255, 255, 255)
draw_row(pdf, COL, headers, HEADER_BG, bold=True)
pdf.set_text_color(0, 0, 0)

rows = [
    ('1',  'Chatbot Backend',   'ecoscan-chatbot.onrender.com',          'EcoBot IA (/chat)'),
    ('2',  'Scan API (YOLOv8)', 'ecoscan-model-online.onrender.com',     'Detection dechets (/scan)'),
    ('3',  'OpenWeatherMap',    'api.openweathermap.org/data/2.5',       'Meteo + qualite de l\'air'),
    ('4',  'OpenFoodFacts',     'world.openfoodfacts.org',               'Donnees produits par code-barre'),
    ('5',  'Cloudinary',        'api.cloudinary.com/v1_1/dfuhrnnxx',     'Upload images marketplace'),
    ('6',  'Firebase (Google)', 'projet ecoscan-8795b',                  'Auth, Firestore, Storage, FCM'),
    ('7',  'n8n Webhooks',      'instance non configuree',               'Alertes + emails automatiques'),
    ('8',  'OpenStreetMap',     'tile.openstreetmap.org',                'Carte points de collecte'),
    ('9',  'Google Maps',       'google.com/maps/dir',                   'Itineraires vers centres de tri'),
    ('10', 'WhatsApp',          'wa.me/',                                'Contact vendeurs marketplace'),
]

for i, row in enumerate(rows):
    bg = ROW_BG1 if i % 2 == 0 else ROW_BG2
    draw_row(pdf, COL, row, bg)

# ── Section 2 ────────────────────────────────────────────────────────────────
pdf.ln(6)
pdf.set_font('Helvetica', 'B', 13)
pdf.set_text_color(34, 139, 34)
pdf.cell(0, 8, 'Backend Chatbot (Python/FastAPI)', ln=True)
pdf.set_text_color(0, 0, 0)
pdf.ln(2)

COL2 = [60, 130]
headers2 = ['Service', 'Detail']
pdf.set_text_color(255, 255, 255)
draw_row(pdf, COL2, headers2, HEADER_BG, bold=True)
pdf.set_text_color(0, 0, 0)

rows2 = [
    ('Google Gemini', 'Modele gemini-2.5-flash via LangChain'),
    ('HuggingFace',   'Embeddings all-MiniLM-L6-v2'),
    ('ChromaDB',      'Base vectorielle locale (RAG)'),
]
for i, row in enumerate(rows2):
    bg = ROW_BG1 if i % 2 == 0 else ROW_BG2
    draw_row(pdf, COL2, row, bg)

out = r'c:\Users\H.Badreddine\Desktop\PFE\ecoscan\EcoScan_APIs.pdf'
pdf.output(out)
print(f'PDF genere : {out}')
