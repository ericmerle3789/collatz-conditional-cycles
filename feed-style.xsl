<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="atom">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:template match="/atom:feed">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>
          <xsl:text>Updates feed — </xsl:text>
          <xsl:value-of select="atom:title"/>
        </title>
        <style>
          /* Autonome — pas de dépendance main.css externe pour éviter Google Fonts stall */
          :root { --bg-primary: #0e0f13; --bg-secondary: #16181f; --text-primary: #e8e6e1; --text-secondary: #999; --accent: #d97706; --border: #2a2d36; }
          html { background: var(--bg-primary); }
          body { background: var(--bg-primary); color: var(--text-primary); margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif; line-height: 1.55; }
          .feed-wrap { max-width: 760px; margin: 3rem auto; padding: 0 1.2rem; }
          .feed-wrap h1 { font-family: Georgia, "Times New Roman", serif; font-size: clamp(1.6rem, 3.5vw, 2.2rem); line-height: 1.2; margin: 0 0 0.5rem; color: var(--text-primary); }
          .feed-wrap h1 br { display: block; }
          .feed-wrap .feed-subtitle { font-style: italic; color: var(--text-secondary); margin: 0 0 2rem; }
          .feed-wrap .feed-intro { background: rgba(217, 119, 6, 0.06); border-left: 3px solid var(--accent); padding: 1rem 1.2rem; border-radius: 4px; margin: 0 0 2rem; }
          .feed-wrap .feed-intro p { margin: 0 0 0.8rem; }
          .feed-wrap .feed-intro p:last-child { margin-bottom: 0; }
          .feed-wrap .feed-intro code { font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.9em; background: rgba(217, 119, 6, 0.1); padding: 0.1em 0.3em; border-radius: 3px; }
          .feed-wrap .feed-url-box { background: var(--bg-secondary); border: 1px solid var(--border); border-radius: 4px; padding: 0.8rem 1rem; display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin: 0 0 2.5rem; flex-wrap: wrap; }
          .feed-wrap .feed-url { font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.92rem; color: var(--accent); word-break: break-all; }
          .feed-wrap .feed-copy-btn { background: var(--accent); color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; font-family: inherit; font-weight: 500; cursor: pointer; white-space: nowrap; font-size: 0.9rem; }
          .feed-wrap .feed-copy-btn:hover { opacity: 0.9; }
          .feed-wrap .feed-copy-toast { color: var(--accent); font-size: 0.88rem; margin-left: 0.5rem; }
          .feed-wrap .feed-entries-heading { font-family: Georgia, "Times New Roman", serif; font-size: 1.3rem; margin: 2rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--border); color: var(--text-primary); }
          .feed-wrap .feed-entry { margin: 0 0 2rem; padding-bottom: 1.5rem; border-bottom: 1px dashed var(--border); }
          .feed-wrap .feed-entry:last-child { border-bottom: none; }
          .feed-wrap .feed-entry-meta { font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.82rem; color: var(--text-secondary); margin: 0 0 0.4rem; }
          .feed-wrap .feed-entry h3 { font-family: Georgia, "Times New Roman", serif; font-size: 1.15rem; margin: 0 0 0.6rem; color: var(--text-primary); }
          .feed-wrap .feed-entry-summary { color: var(--text-primary); font-size: 0.95rem; line-height: 1.55; }
          .feed-wrap .feed-entry-summary p { margin: 0 0 0.6rem; }
          .feed-wrap .feed-entry-summary code { font-family: ui-monospace, "SF Mono", Menlo, monospace; background: rgba(217, 119, 6, 0.08); padding: 0.1em 0.3em; border-radius: 3px; font-size: 0.88em; }
          .feed-wrap .feed-entry-summary a { color: var(--accent); }
          .feed-wrap .feed-entry-link { display: inline-block; margin-top: 0.6rem; color: var(--accent); text-decoration: none; font-size: 0.9rem; }
          .feed-wrap .feed-entry-link:hover { text-decoration: underline; }
          .feed-wrap .feed-footer { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid var(--border); color: var(--text-secondary); font-size: 0.85rem; }
          .feed-wrap .feed-footer p { margin: 0 0 0.4rem; }
          .feed-wrap .feed-footer a { color: var(--accent); text-decoration: none; }
          .feed-wrap .feed-footer a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <main class="feed-wrap">
          <h1>
            <span lang="en">Updates feed — collatz-lab.org</span>
            <br/>
            <span lang="fr">Flux des mises à jour — collatz-lab.org</span>
          </h1>
          <p class="feed-subtitle">
            <xsl:value-of select="atom:subtitle"/>
          </p>

          <div class="feed-intro">
            <p>
              <span lang="fr">🇫🇷 Cette page est un flux Atom (standard RSS) listant les mises à jour de <code>collatz-lab.org</code>. Pour suivre les nouvelles versions sans intermédiaire, ajoute l'URL ci-dessous dans un lecteur de flux (NetNewsWire, Feedly, Inoreader, ou ton client mail s'il supporte les flux).</span>
            </p>
            <p>
              <span lang="en">🇬🇧 This page is an Atom feed (RSS standard) listing updates to <code>collatz-lab.org</code>. To follow new releases without intermediaries, add the URL below to a feed reader (NetNewsWire, Feedly, Inoreader, or your mail client if it supports feeds).</span>
            </p>
          </div>

          <div class="feed-url-box">
            <code class="feed-url" id="feed-url-text">https://collatz-lab.org/feed.xml</code>
            <button class="feed-copy-btn" id="feed-copy-btn">📋 Copier / Copy</button>
            <span class="feed-copy-toast" id="feed-copy-toast" style="display:none">✓ Copié / Copied</span>
          </div>
          <script>
            <xsl:text disable-output-escaping="yes"><![CDATA[
              (function() {
                var btn = document.getElementById('feed-copy-btn');
                var toast = document.getElementById('feed-copy-toast');
                var urlText = document.getElementById('feed-url-text');
                if (!btn) return;
                btn.addEventListener('click', function() {
                  var url = 'https://collatz-lab.org/feed.xml';
                  if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(url).then(function() {
                      toast.style.display = 'inline';
                      setTimeout(function() { toast.style.display = 'none'; }, 2000);
                    }).catch(function() {
                      var r = document.createRange();
                      r.selectNode(urlText);
                      window.getSelection().removeAllRanges();
                      window.getSelection().addRange(r);
                    });
                  } else {
                    var r = document.createRange();
                    r.selectNode(urlText);
                    window.getSelection().removeAllRanges();
                    window.getSelection().addRange(r);
                  }
                });
              })();
            ]]></xsl:text>
          </script>

          <h2 class="feed-entries-heading">
            <span lang="en">Latest entries</span>
            <span class="lang-sep"> · </span>
            <span lang="fr">Dernières entrées</span>
          </h2>

          <xsl:for-each select="atom:entry">
            <article class="feed-entry">
              <p class="feed-entry-meta">
                <xsl:value-of select="substring(atom:updated, 1, 10)"/>
              </p>
              <h3>
                <xsl:value-of select="atom:title"/>
              </h3>
              <div class="feed-entry-summary">
                <xsl:value-of select="atom:summary" disable-output-escaping="yes"/>
              </div>
              <a class="feed-entry-link">
                <xsl:attribute name="href">
                  <xsl:value-of select="atom:link/@href"/>
                </xsl:attribute>
                <span lang="en">Read on the site</span>
                <span class="lang-sep"> · </span>
                <span lang="fr">Lire sur le site</span>
                <xsl:text> →</xsl:text>
              </a>
            </article>
          </xsl:for-each>

          <footer class="feed-footer">
            <p>
              <span lang="fr">Cette page est un flux XML transformé pour la lecture humaine via XSLT. Le XML brut reste valide pour les lecteurs automatiques.</span>
            </p>
            <p>
              <span lang="en">This is an XML feed transformed for human reading via XSLT. The raw XML remains valid for automated readers.</span>
            </p>
            <p>
              <a href="/">
                <xsl:text>← </xsl:text>
                <span lang="en">Back to collatz-lab.org</span>
                <span class="lang-sep"> · </span>
                <span lang="fr">Retour à collatz-lab.org</span>
              </a>
            </p>
          </footer>
        </main>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
