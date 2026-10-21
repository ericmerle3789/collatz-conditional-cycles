/* ==========================================================================
   Theorem Dependency Graph — D3 force-directed visualization
   Affiche l'architecture de la preuve : 3 hypothèses H1-H3 (paramètres des
   théorèmes, pas des axiomes Lean), lemmes auxiliaires, théorèmes centraux et
   no_nontrivial_cycle_phase59. Arêtes vérifiées contre le code (branche main,
   Phase52/56/58/59) le 2026-10-02 : H3 n'alimente que no_cycle_k_gt_1322 ;
   sdw_from_cf est un corollaire en aval ; les cf_gap_* ne sont utilisés par
   aucun théorème de la chaîne principale.
   ========================================================================== */
(function() {
  'use strict';

  // Catégorisation visuelle des nœuds
  const NODE_TYPE = {
    EXTERNAL: 'external',     // hypothèses H1-H3, paramètres des théorèmes (BakerSeparation, BarinaVerification, DerivedLargeKBound)
    KERNEL: 'kernel',          // axiomes Lean kernel
    AUXILIARY: 'auxiliary',    // lemmes auxiliaires
    CENTRAL: 'central',        // théorèmes centraux
    MAIN: 'main'               // résultat principal (theorem)
  };

  const COLOR = {
    [NODE_TYPE.EXTERNAL]:  '#9080a8',   // violet
    [NODE_TYPE.KERNEL]:    '#6a9b7a',   // vert
    [NODE_TYPE.AUXILIARY]: '#6a93b8',   // bleu
    [NODE_TYPE.CENTRAL]:   '#d4a045',   // amber
    [NODE_TYPE.MAIN]:      '#c8a86a'    // accent doré
  };

  const RADIUS = {
    [NODE_TYPE.EXTERNAL]:  18,
    [NODE_TYPE.KERNEL]:    12,
    [NODE_TYPE.AUXILIARY]: 14,
    [NODE_TYPE.CENTRAL]:   18,
    [NODE_TYPE.MAIN]:      28
  };

  // Architecture de la preuve (extraite du Mermaid de /preuve/ + lemmes.json)
  const NODES = [
    // Hypothèses H1-H3 (paramètres des théorèmes, pas des axiomes Lean)
    { id: 'BakerSeparation', type: NODE_TYPE.EXTERNAL, label: 'H1 BakerSeparation', sub: 'parameter: (2^s − 3^k)·k^6 ≥ 3^k — working hypothesis, stronger in this form than published effective bounds (see mea culpa #28)' },
    { id: 'BarinaVerification', type: NODE_TYPE.EXTERNAL, label: 'H2 BarinaVerification', sub: 'parameter: encoding of a published computational result (Barina 2025, n < 2⁷¹)' },
    { id: 'DerivedLargeKBound', type: NODE_TYPE.EXTERNAL, label: 'H3 DerivedLargeKBound', sub: 'parameter: k > 1322 → n < 2⁷¹ — assumed hypothesis (not derived); under H2 equivalent to the conclusion itself (in Lean, k is any return time) (erratum of 2 Oct 2026; HYPOTHESES.md, section H3)' },
    // Axiomes kernel (profil du théorème principal selon expected_axioms.md, Lean 4.27.0)
    { id: 'propext', type: NODE_TYPE.KERNEL, label: 'propext', sub: 'Propositional extensionality' },
    { id: 'Classical.choice', type: NODE_TYPE.KERNEL, label: 'Classical.choice', sub: 'Axiom of choice' },
    { id: 'Quot.sound', type: NODE_TYPE.KERNEL, label: 'Quot.sound', sub: 'Quotient soundness' },
    // Lemmes auxiliaires
    { id: 'steiner_cycle_eq', type: NODE_TYPE.AUXILIARY, label: 'steiner_cycle_eq', sub: 'Steiner identity (Phase52); used by R72 (arsenal)' },
    { id: 'cycle_min_bound_nat', type: NODE_TYPE.AUXILIARY, label: 'cycle_min_bound_nat', sub: 'Product Bound n ≤ (k^7+k)/3, uses H1 (Phase56)' },
    { id: 'cycle_pow2_gt_pow3', type: NODE_TYPE.AUXILIARY, label: 'cycle_pow2_gt_pow3', sub: '2^S > 3^k (Phase50); used by the Product Bound and, via cycle_pow2_gt_pow3_universal, by R72' },
    { id: 'cycle_n_mul_D_s_eq_corrSum', type: NODE_TYPE.AUXILIARY, label: 'R72 factored', sub: 'PostJAR CongruenceTransport (arsenal-postjar branch)' },
    { id: 'cycle_corrSum_mod_p_double_periodic', type: NODE_TYPE.AUXILIARY, label: 'R89 lacunary', sub: 'PostJAR CongruenceTransport (arsenal-postjar branch)' },
    { id: 'cf_gap_8_to_13', type: NODE_TYPE.AUXILIARY, label: 'cf_gap_8 … cf_gap_13', sub: 'Phase59 native_decide (6 windows) — isolated arithmetic checks, used by no theorem of the main chain; they do not prove H3' },
    // Sous-branches centrales
    { id: 'no_cycle_k_le_1322', type: NODE_TYPE.CENTRAL, label: 'no_cycle_k_le_1322', sub: 'k ≤ 1322 — Product Bound (H1) + Barina (H2); re-checked on Lean 4.34.0 (20–21 Oct 2026)' },
    { id: 'no_cycle_k_gt_1322', type: NODE_TYPE.CENTRAL, label: 'no_cycle_k_gt_1322', sub: 'k > 1322 — only H3 (assumed) + H2; circular (erratum of 2 Oct 2026)' },
    { id: 'sdw_from_cf', type: NODE_TYPE.CENTRAL, label: 'sdw_from_cf', sub: 'downstream corollary: ProductBoundThreshold (k ≤ 982), vacuous under H1–H3' },
    // Théorème principal + 3 variantes (autres hypothèses)
    { id: 'no_nontrivial_cycle_phase59', type: NODE_TYPE.MAIN, label: 'no_nontrivial_cycle_phase59', sub: 'Main theorem (H1, H2, H3) — Lean 4.27.0, not re-checked after lean4#14576; adds nothing beyond k ≤ 1322 (erratum)' },
    { id: 'no_nontrivial_cycle_final', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_final', sub: 'variant with ProductBoundThreshold as 3rd hypothesis (statement of the Zenodo PDF)' },
    { id: 'no_nontrivial_cycle_derived', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_derived', sub: 'variant with hypothesis structure ExternalCycleHypothesesDerived (Phase56)' },
    { id: 'no_nontrivial_cycle_full', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_full', sub: 'variant assuming every cycle element < 2⁷¹ (Phase52)' }
  ];

  const LINKS = [
    // Hypothèses vers théorèmes (paramètres effectivement utilisés)
    { source: 'BakerSeparation', target: 'cycle_min_bound_nat' },
    { source: 'BarinaVerification', target: 'no_cycle_k_le_1322' },
    { source: 'BarinaVerification', target: 'no_cycle_k_gt_1322' },
    { source: 'DerivedLargeKBound', target: 'no_cycle_k_gt_1322' },
    // Axiomes kernel vers résultat principal
    { source: 'propext', target: 'no_nontrivial_cycle_phase59', kernel: true },
    { source: 'Classical.choice', target: 'no_nontrivial_cycle_phase59', kernel: true },
    { source: 'Quot.sound', target: 'no_nontrivial_cycle_phase59', kernel: true },
    // Auxiliaires
    { source: 'cycle_min_bound_nat', target: 'no_cycle_k_le_1322' },
    { source: 'steiner_cycle_eq', target: 'cycle_n_mul_D_s_eq_corrSum' },
    { source: 'cycle_pow2_gt_pow3', target: 'cycle_min_bound_nat' },
    { source: 'cycle_pow2_gt_pow3', target: 'cycle_n_mul_D_s_eq_corrSum' },
    // Sous-branches vers principal et corollaire en aval
    { source: 'no_cycle_k_le_1322', target: 'no_nontrivial_cycle_phase59' },
    { source: 'no_cycle_k_gt_1322', target: 'no_nontrivial_cycle_phase59' },
    { source: 'no_cycle_k_le_1322', target: 'sdw_from_cf' },
    { source: 'no_cycle_k_gt_1322', target: 'sdw_from_cf' },
    // Variantes (autres hypothèses) et leur dépendance réelle
    { source: 'no_nontrivial_cycle_derived', target: 'no_nontrivial_cycle_final' }
  ];

  function init(containerId) {
    const container = document.getElementById(containerId);
    if (!container || !window.d3) return;

    // Cleanup precedent svg
    container.innerHTML = '';

    const W = container.clientWidth || 900;
    const H = 600;
    const isLight = document.documentElement.dataset.theme === 'light';

    const svg = d3.select(container).append('svg')
      .attr('viewBox', `0 0 ${W} ${H}`)
      .attr('preserveAspectRatio', 'xMidYMid meet')
      .style('width', '100%')
      .style('height', H + 'px')
      .style('cursor', 'grab');

    // Defs : arrowheads
    const defs = svg.append('defs');
    defs.append('marker')
      .attr('id', 'arrow-default')
      .attr('viewBox', '0 -5 10 10')
      .attr('refX', 22)
      .attr('refY', 0)
      .attr('markerWidth', 7)
      .attr('markerHeight', 7)
      .attr('orient', 'auto')
      .append('path')
      .attr('d', 'M0,-5L10,0L0,5')
      .attr('fill', isLight ? '#6b6760' : '#8b887f');

    defs.append('marker')
      .attr('id', 'arrow-alias')
      .attr('viewBox', '0 -5 10 10')
      .attr('refX', 22)
      .attr('refY', 0)
      .attr('markerWidth', 7)
      .attr('markerHeight', 7)
      .attr('orient', 'auto')
      .append('path')
      .attr('d', 'M0,-5L10,0L0,5')
      .attr('fill', '#c8a86a');

    // Container avec zoom
    const g = svg.append('g');
    svg.call(d3.zoom()
      .scaleExtent([0.4, 2.5])
      .on('zoom', (e) => g.attr('transform', e.transform)));

    // Simulation forcée
    // Clone nodes/links pour ne pas muter les sources
    const nodesClone = NODES.map(d => ({ ...d }));
    const linksClone = LINKS.map(d => ({ ...d }));
    const sim = d3.forceSimulation(nodesClone)
      .force('link', d3.forceLink(linksClone).id(d => d.id).distance(d => d.kernel ? 60 : (d.alias ? 60 : 110)).strength(d => d.alias ? 0.4 : 0.7))
      .force('charge', d3.forceManyBody().strength(-340))
      .force('center', d3.forceCenter(W / 2, H / 2))
      .force('collide', d3.forceCollide().radius(d => RADIUS[d.type] + 10).strength(0.9))
      .force('x', d3.forceX(W / 2).strength(0.04))
      .force('y', d3.forceY().y(d => {
        if (d.type === NODE_TYPE.EXTERNAL || d.type === NODE_TYPE.KERNEL) return 80;
        if (d.type === NODE_TYPE.AUXILIARY) return H * 0.4;
        if (d.type === NODE_TYPE.CENTRAL) return H * 0.7;
        if (d.type === NODE_TYPE.MAIN) return H - 100;
        return H / 2;
      }).strength(0.18));

    // Liens
    const link = g.append('g')
      .attr('class', 'links')
      .attr('stroke', isLight ? '#6b6760' : '#8b887f')
      .attr('stroke-opacity', 0.55)
      .selectAll('line')
      .data(linksClone)
      .join('line')
      .attr('stroke-width', d => d.alias ? 1 : (d.kernel ? 0.8 : 1.5))
      .attr('stroke-dasharray', d => d.alias ? '4 3' : (d.kernel ? '2 2' : null))
      .attr('stroke', d => d.alias ? '#c8a86a' : (isLight ? '#6b6760' : '#8b887f'))
      .attr('marker-end', d => d.alias ? 'url(#arrow-alias)' : 'url(#arrow-default)');

    // Nœuds (group avec drag)
    const node = g.append('g')
      .attr('class', 'nodes')
      .selectAll('g')
      .data(nodesClone)
      .join('g')
      .style('cursor', 'pointer')
      .call(d3.drag()
        .on('start', (event, d) => {
          if (!event.active) sim.alphaTarget(0.3).restart();
          d.fx = d.x; d.fy = d.y;
        })
        .on('drag', (event, d) => { d.fx = event.x; d.fy = event.y; })
        .on('end', (event, d) => {
          if (!event.active) sim.alphaTarget(0);
          d.fx = null; d.fy = null;
        }));

    node.append('circle')
      .attr('r', d => RADIUS[d.type])
      .attr('fill', d => COLOR[d.type])
      .attr('stroke', d => d.type === NODE_TYPE.MAIN ? '#fff' : 'rgba(255,255,255,0.2)')
      .attr('stroke-width', d => d.type === NODE_TYPE.MAIN ? 2.5 : 1)
      .attr('opacity', 0.92);

    // Étoile pour le résultat principal
    node.filter(d => d.type === NODE_TYPE.MAIN)
      .append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', '0.35em')
      .attr('fill', '#0e0f13')
      .attr('font-size', '20px')
      .attr('font-weight', 'bold')
      .text('★');

    // Labels
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', d => RADIUS[d.type] + 14)
      .attr('font-size', d => d.type === NODE_TYPE.MAIN ? '12px' : '10px')
      .attr('font-weight', d => d.type === NODE_TYPE.MAIN ? '700' : '500')
      .attr('fill', isLight ? '#1a1a1a' : '#e8e6e0')
      .attr('font-family', 'JetBrains Mono, monospace')
      .text(d => d.label);

    // Tooltip au hover
    node.append('title')
      .text(d => d.label + '\n' + (d.sub || ''));

    // Click → open piste/cite modal si pertinent
    node.on('click', (event, d) => {
      const tooltipDiv = document.getElementById('graph-tooltip');
      if (tooltipDiv) {
        tooltipDiv.innerHTML = `
          <div class="graph-tooltip-type" style="color:${COLOR[d.type]}">${d.type.toUpperCase()}</div>
          <div class="graph-tooltip-name">${d.label}</div>
          <div class="graph-tooltip-sub">${d.sub || ''}</div>
        `;
        tooltipDiv.style.display = 'block';
      }
    });

    sim.on('tick', () => {
      link
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);
      node.attr('transform', d => `translate(${d.x},${d.y})`);
    });

    // Re-render on theme change
    new MutationObserver(() => init(containerId))
      .observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
  }

  // Expose
  window.CollatzDependencyGraph = { init, NODES, LINKS };
})();
