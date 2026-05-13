/* ==========================================================================
   Theorem Dependency Graph — D3 force-directed visualization
   Affiche l'architecture complète de la preuve : 3 axiomes externes
   alimentent 6 lemmes auxiliaires, qui alimentent 7 théorèmes centraux
   convergant vers no_nontrivial_cycle_phase59.
   ========================================================================== */
(function() {
  'use strict';

  // Catégorisation visuelle des nœuds
  const NODE_TYPE = {
    EXTERNAL: 'external',     // axiomes externes documentés (Baker, Barina, Hercher)
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
    // Axiomes externes (3 conditions du résultat principal)
    { id: 'BakerSeparation', type: NODE_TYPE.EXTERNAL, label: 'BakerSeparation', sub: 'effective: (2^s − 3^k)·k^6 ≥ 3^k (working conjecture, undemonstrated strengthening of Rhin/Wu/Salikhov — see #28, δ10)' },
    { id: 'BarinaVerification', type: NODE_TYPE.EXTERNAL, label: 'BarinaVerification', sub: 'Barina 2025 — n < 2⁷¹' },
    { id: 'DerivedLargeKBound', type: NODE_TYPE.EXTERNAL, label: 'DerivedLargeKBound', sub: 'Hercher 2023 — m ≤ 91' },
    // Axiomes kernel (3 universels)
    { id: 'propext', type: NODE_TYPE.KERNEL, label: 'propext', sub: 'Propositional extensionality' },
    { id: 'Classical.choice', type: NODE_TYPE.KERNEL, label: 'Classical.choice', sub: 'Axiom of choice' },
    { id: 'Quot.sound', type: NODE_TYPE.KERNEL, label: 'Quot.sound', sub: 'Quotient soundness' },
    // Lemmes auxiliaires (Phase 52 + Phase 59 + PostJAR)
    { id: 'steiner_cycle_eq', type: NODE_TYPE.AUXILIARY, label: 'steiner_cycle_eq', sub: 'Steiner identity (Phase52)' },
    { id: 'cycle_pow2_gt_pow3_universal', type: NODE_TYPE.AUXILIARY, label: 'cycle_pow2_gt_pow3', sub: 'D_s positive (Phase52)' },
    { id: 'cycle_n_mul_D_s_eq_corrSum', type: NODE_TYPE.AUXILIARY, label: 'R72 factored', sub: 'PostJAR CongruenceTransport' },
    { id: 'cycle_corrSum_mod_p_double_periodic', type: NODE_TYPE.AUXILIARY, label: 'R89 lacunary', sub: 'PostJAR CongruenceTransport' },
    { id: 'cf_gap_8_to_13', type: NODE_TYPE.AUXILIARY, label: 'cf_gap_8 … cf_gap_13', sub: 'Phase59 native_decide (6 windows)' },
    // Sous-branches centrales
    { id: 'no_cycle_k_le_1322', type: NODE_TYPE.CENTRAL, label: 'no_cycle_k_le_1322', sub: 'k ≤ 1322 — Barina + ProductBound' },
    { id: 'no_cycle_k_gt_1322', type: NODE_TYPE.CENTRAL, label: 'no_cycle_k_gt_1322', sub: 'k > 1322 — continued fractions' },
    { id: 'sdw_from_cf', type: NODE_TYPE.CENTRAL, label: 'sdw_from_cf', sub: 'Simons-de Weger from CF' },
    // Théorème principal + 3 alias
    { id: 'no_nontrivial_cycle_phase59', type: NODE_TYPE.MAIN, label: 'no_nontrivial_cycle_phase59', sub: '★ Main result — kernel-checked' },
    { id: 'no_nontrivial_cycle_final', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_final', sub: 'alias variant' },
    { id: 'no_nontrivial_cycle_derived', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_derived', sub: 'cleanup alias' },
    { id: 'no_nontrivial_cycle_full', type: NODE_TYPE.CENTRAL, label: 'no_nontrivial_cycle_full', sub: 'extended alias' }
  ];

  const LINKS = [
    // Axiomes externes vers sous-branches
    { source: 'BakerSeparation', target: 'no_cycle_k_le_1322' },
    { source: 'BakerSeparation', target: 'sdw_from_cf' },
    { source: 'BarinaVerification', target: 'no_cycle_k_le_1322' },
    { source: 'DerivedLargeKBound', target: 'no_cycle_k_le_1322' },
    // Axiomes kernel vers résultat principal (universel sur tous les théorèmes)
    { source: 'propext', target: 'no_nontrivial_cycle_phase59', kernel: true },
    { source: 'Classical.choice', target: 'no_nontrivial_cycle_phase59', kernel: true },
    { source: 'Quot.sound', target: 'no_nontrivial_cycle_phase59', kernel: true },
    // Auxiliaires vers sous-branches
    { source: 'steiner_cycle_eq', target: 'no_cycle_k_le_1322' },
    { source: 'steiner_cycle_eq', target: 'no_cycle_k_gt_1322' },
    { source: 'cycle_pow2_gt_pow3_universal', target: 'no_cycle_k_le_1322' },
    { source: 'cycle_pow2_gt_pow3_universal', target: 'no_cycle_k_gt_1322' },
    { source: 'cycle_n_mul_D_s_eq_corrSum', target: 'cycle_corrSum_mod_p_double_periodic' },
    { source: 'cf_gap_8_to_13', target: 'sdw_from_cf' },
    { source: 'sdw_from_cf', target: 'no_cycle_k_gt_1322' },
    // Sous-branches vers principal
    { source: 'no_cycle_k_le_1322', target: 'no_nontrivial_cycle_phase59' },
    { source: 'no_cycle_k_gt_1322', target: 'no_nontrivial_cycle_phase59' },
    // Alias liés au principal
    { source: 'no_nontrivial_cycle_phase59', target: 'no_nontrivial_cycle_final', alias: true },
    { source: 'no_nontrivial_cycle_phase59', target: 'no_nontrivial_cycle_derived', alias: true },
    { source: 'no_nontrivial_cycle_phase59', target: 'no_nontrivial_cycle_full', alias: true }
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
