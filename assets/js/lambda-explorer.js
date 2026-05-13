/* ==========================================================================
   Lambda Explorer — visualisation interactive du verrou Λ_{S,k}
   Plot dans le plan (k, S) avec :
   - droite y = k log_2 3 (cycle approximatif)
   - région Barina k ≤ 1322 (rouge)
   - région DerivedLargeKBound (dérivation projet, k > 1322) — amber
   - bande BakerSeparation effective (bleu, autour de la droite)
   - point courant (S, k) cliqué/sliders
   ========================================================================== */
(function() {
  'use strict';

  const LOG2 = Math.log(2);
  const LOG3 = Math.log(3);
  const LOG2_3 = LOG3 / LOG2; // ≈ 1.585

  function init() {
    const canvas = document.getElementById('lambdaCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    // Plage : k de 1 à 2000, S de 1 à 3000 (mais affiché jusqu'à K_MAX*log_2_3 + buffer)
    const K_MAX = 2000;
    const S_MAX = K_MAX * LOG2_3 + 200;

    function isLight() {
      return document.documentElement.dataset.theme === 'light';
    }

    function project(k, S) {
      // (k, S) → pixel
      const W = canvas.width;
      const H = canvas.height;
      const pad = 50;
      const x = pad + (k / K_MAX) * (W - 2 * pad);
      const y = H - pad - (S / S_MAX) * (H - 2 * pad);
      return [x, y];
    }

    function drawAxes() {
      const W = canvas.width;
      const H = canvas.height;
      const pad = 50;
      ctx.strokeStyle = isLight() ? '#6b6760' : '#8b887f';
      ctx.lineWidth = 1;
      ctx.fillStyle = isLight() ? '#3d3a35' : '#b8b5ad';
      ctx.font = '12px Inter, sans-serif';

      // Axe X (k)
      ctx.beginPath();
      ctx.moveTo(pad, H - pad);
      ctx.lineTo(W - pad, H - pad);
      ctx.stroke();
      ctx.fillText('k →', W - pad - 20, H - pad + 30);

      // Axe Y (S)
      ctx.beginPath();
      ctx.moveTo(pad, H - pad);
      ctx.lineTo(pad, pad);
      ctx.stroke();
      ctx.fillText('S ↑', pad - 30, pad + 5);

      // Graduations k
      ctx.fillStyle = isLight() ? '#6b6760' : '#8b887f';
      ctx.font = '10px JetBrains Mono, monospace';
      [0, 500, 1000, 1322, 1500, 2000].forEach(k => {
        const [x, y] = project(k, 0);
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x, y + 5);
        ctx.stroke();
        ctx.textAlign = 'center';
        ctx.fillText(k, x, y + 18);
      });
      ctx.textAlign = 'left';

      // Graduations S
      [0, 1000, 2000, 3000].forEach(S => {
        const [x, y] = project(0, S);
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x - 5, y);
        ctx.stroke();
        ctx.textAlign = 'right';
        ctx.fillText(S, x - 8, y + 4);
      });
      ctx.textAlign = 'left';
    }

    function drawBakerBand() {
      // Baker borne |S log 2 - k log 3| > C/k^7. Bande étroite autour de S = k log_2(3)
      // Pour visualiser, on dessine une bande "Baker active" pour k ≥ 1
      ctx.fillStyle = 'rgba(106, 147, 184, 0.15)';
      ctx.beginPath();
      const W = canvas.width;
      const H = canvas.height;
      // Bande de demi-largeur 3 unités en S autour de y = k * LOG2_3
      const halfW = 3;
      const start = project(1, 1 * LOG2_3 - halfW);
      ctx.moveTo(start[0], start[1]);
      for (let k = 1; k <= K_MAX; k += 20) {
        const [x, y] = project(k, k * LOG2_3 - halfW);
        ctx.lineTo(x, y);
      }
      for (let k = K_MAX; k >= 1; k -= 20) {
        const [x, y] = project(k, k * LOG2_3 + halfW);
        ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.fill();
    }

    function drawBarinaRegion() {
      // Barina exclut k ≤ 1322 (en pratique : tous les cycles avec n < 2^71)
      // On hachure la zone k ≤ 1322 avec un fill rouge léger
      ctx.fillStyle = 'rgba(194, 84, 80, 0.18)';
      const [x0, y0] = project(0, 0);
      const [x1, y1] = project(1322, 0);
      const [x2, y2] = project(1322, S_MAX);
      const [x3, y3] = project(0, S_MAX);
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      ctx.lineTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.lineTo(x3, y3);
      ctx.closePath();
      ctx.fill();
      // Label
      ctx.fillStyle = '#c25450';
      ctx.font = 'bold 11px JetBrains Mono';
      ctx.fillText('Barina k ≤ 1322', x0 + 15, y3 + 25);
    }

    function drawDerivedLargeKBoundRegion() {
      // DerivedLargeKBound (dérivation projet) : k > 1322 ⇒ n < 2^71
      // Région visualisée : bande k ∈ (1322, K_MAX)
      ctx.fillStyle = 'rgba(212, 160, 69, 0.10)';
      const [x0, y0] = project(1322, 0);
      const [x1, y1] = project(K_MAX, 0);
      const [x2, y2] = project(K_MAX, S_MAX);
      const [x3, y3] = project(1322, S_MAX);
      ctx.beginPath();
      ctx.moveTo(x0, y0);
      ctx.lineTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.lineTo(x3, y3);
      ctx.closePath();
      ctx.fill();
      ctx.fillStyle = '#d4a045';
      ctx.font = 'bold 11px JetBrains Mono';
      ctx.fillText('DerivedLargeKBound (k > 1322)', x0 + 15, y3 + 25);
    }

    function drawCycleLine() {
      // Droite S = k * log_2(3)
      ctx.strokeStyle = '#6a9b7a';
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      ctx.beginPath();
      const start = project(0, 0);
      ctx.moveTo(start[0], start[1]);
      const end = project(K_MAX, K_MAX * LOG2_3);
      ctx.lineTo(end[0], end[1]);
      ctx.stroke();
      ctx.setLineDash([]);

      // Label
      ctx.save();
      ctx.translate(end[0] - 60, end[1] + 10);
      ctx.rotate(-Math.atan2((end[1] - start[1]), (end[0] - start[0])));
      ctx.fillStyle = '#6a9b7a';
      ctx.font = 'italic 11px Inter';
      ctx.fillText('S = k · log₂ 3', 0, 0);
      ctx.restore();
    }

    function drawCurrentPoint(S, k) {
      const [x, y] = project(k, S);
      // Halo
      const grad = ctx.createRadialGradient(x, y, 0, x, y, 25);
      grad.addColorStop(0, 'rgba(200, 168, 106, 0.6)');
      grad.addColorStop(1, 'rgba(200, 168, 106, 0)');
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(x, y, 25, 0, Math.PI * 2);
      ctx.fill();

      // Point central
      ctx.fillStyle = '#c8a86a';
      ctx.strokeStyle = isLight() ? '#1a1a1a' : '#fff';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(x, y, 7, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();

      // Label
      ctx.fillStyle = isLight() ? '#1a1a1a' : '#e8e6e0';
      ctx.font = 'bold 12px JetBrains Mono';
      ctx.fillText(`(${k}, ${S})`, x + 12, y - 10);
    }

    function lambdaValue(S, k) {
      return S * LOG2 - k * LOG3;
    }

    function classifyPoint(S, k) {
      const lambda = lambdaValue(S, k);
      const lambdaAbs = Math.abs(lambda);
      const closeToCycle = lambdaAbs < 1.5;
      const inBarina = k <= 1322;
      const inDerivedLargeK = k > 1322;

      if (!closeToCycle) {
        return {
          status: 'far',
          fr: '✗ Hors hypothèse de cycle (Λ trop éloigné de 0)',
          en: '✗ Outside cycle hypothesis (Λ too far from 0)'
        };
      }
      if (inBarina) {
        return {
          status: 'barina',
          fr: '⊕ Région Barina + Product-Bound : exclu pour n < 2⁷¹',
          en: '⊕ Barina + Product-Bound region: excluded for n < 2⁷¹'
        };
      }
      if (inDerivedLargeK) {
        return {
          status: 'derived-large-k',
          fr: '⊕ Région DerivedLargeKBound (dérivation projet) + BakerSeparation effective : exclu via continued fractions',
          en: '⊕ DerivedLargeKBound (project-derived) + BakerSeparation effective region: excluded via continued fractions'
        };
      }
      return { status: 'unknown', fr: '?', en: '?' };
    }

    function render() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawAxes();
      drawBarinaRegion();
      drawDerivedLargeKBoundRegion();
      drawBakerBand();
      drawCycleLine();

      const S = parseInt(document.getElementById('sliderS').value, 10);
      const k = parseInt(document.getElementById('sliderK').value, 10);
      drawCurrentPoint(S, k);

      // Update legend values
      document.getElementById('valS').textContent = S;
      document.getElementById('valK').textContent = k;
      const lambda = lambdaValue(S, k);
      const lambdaEl = document.getElementById('lambdaValue');
      const sign = lambda >= 0 ? '+' : '';
      lambdaEl.textContent = `${sign}${lambda.toFixed(4)}`;
      lambdaEl.style.color = Math.abs(lambda) < 1.5 ? '#c8a86a' : '#8b887f';

      // Classification
      const cls = classifyPoint(S, k);
      const lang = document.documentElement.dataset.lang || 'en';
      const statusEl = document.getElementById('lambdaStatus');
      statusEl.textContent = cls[lang] || cls.en;
      statusEl.className = 'lambda-status status-' + cls.status;
    }

    function bindSliders() {
      ['sliderS', 'sliderK'].forEach(id => {
        document.getElementById(id).addEventListener('input', render);
      });
    }

    // Click on canvas → set S/k
    canvas.addEventListener('click', (e) => {
      const rect = canvas.getBoundingClientRect();
      const cx = (e.clientX - rect.left) * (canvas.width / rect.width);
      const cy = (e.clientY - rect.top) * (canvas.height / rect.height);
      const W = canvas.width, H = canvas.height, pad = 50;
      const k = Math.round(((cx - pad) / (W - 2 * pad)) * K_MAX);
      const S = Math.round(((H - pad - cy) / (H - 2 * pad)) * S_MAX);
      if (k >= 1 && k <= K_MAX && S >= 1 && S <= S_MAX) {
        document.getElementById('sliderS').value = S;
        document.getElementById('sliderK').value = k;
        render();
      }
    });

    bindSliders();
    render();

    // Re-render on theme change
    new MutationObserver(render).observe(document.documentElement, {
      attributes: true, attributeFilter: ['data-theme', 'data-lang']
    });
  }

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    setTimeout(init, 100);
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }
})();
