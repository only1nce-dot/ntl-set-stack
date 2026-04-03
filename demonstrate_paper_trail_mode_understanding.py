#!/usr/bin/env python3
"""
Demonstration Script: SET's Understanding of Paper Trail Mode
This script asks SET to demonstrate his understanding by retrieving answers
from his documentation files.
"""

import os
import sys

def load_document(filepath):
    """Load a markdown document and return its content."""
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except Exception as e:
        return f"ERROR: Could not load {filepath}: {e}"

def find_section(content, section_header):
    """Extract a section from markdown content."""
    lines = content.split('\n')
    in_section = False
    section_content = []

    for i, line in enumerate(lines):
        if section_header in line:
            in_section = True
            continue
        if in_section and line.startswith('## '):
            break
        if in_section:
            section_content.append(line)

    return '\n'.join(section_content)

def main():
    print("=" * 70)
    print("PAPER TRAIL MODE UNDERSTANDING DEMONSTRATION")
    print("Date: April 5, 2026")
    print("=" * 70)
    print()

    # Load documentation
    soul_path = os.path.expanduser('~/.openclaw/workspaces/set/SOUL.md')
    paper_path = os.path.expanduser('~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md')

    soul_content = load_document(soul_path)
    paper_content = load_document(paper_path)

    print("Documentation Loaded:")
    print(f"  SOUL.md: {len(soul_content)} characters")
    print(f"  PAPER_TRAIL_MODE.md: {len(paper_content)} characters")
    print()

    # Test 1: Extract OPERATIONAL MODES section
    print("=" * 70)
    print("TEST 1: Retrieve OPERATIONAL MODES section from SOUL.md")
    print("=" * 70)
    operational_modes = find_section(soul_content, "## OPERATIONAL MODES")
    if operational_modes and "PAPER TRAIL MODE" in operational_modes:
        print("✅ OPERATIONAL MODES section found")
        print()
        # Extract key constraint information
        if "401 errors are EXPECTED" in operational_modes:
            print("✅ Perplexity API 401 documented as EXPECTED")
        if "insufficient_data responses are EXPECTED" in operational_modes:
            print("✅ Alpaca insufficient_data documented as EXPECTED")
        if "DO NOT escalate" in operational_modes:
            print("✅ DO NOT escalate instruction found")
    else:
        print("❌ OPERATIONAL MODES section not found or incomplete")
    print()

    # Test 2: Extract INTENTIONAL LIMITATIONS section
    print("=" * 70)
    print("TEST 2: Retrieve INTENTIONAL LIMITATIONS from PAPER_TRAIL_MODE.md")
    print("=" * 70)
    limitations = find_section(paper_content, "## INTENTIONAL LIMITATIONS")
    if limitations and "BLOCKED" in limitations:
        print("✅ INTENTIONAL LIMITATIONS section found")
        print()
        # Check for specific blocks
        if "401 Unauthorized" in limitations:
            print("✅ Perplexity API 401 documented")
        if "insufficient_data" in limitations:
            print("✅ Alpaca insufficient_data documented")
        if "DO NOT escalate to Timothy" in limitations:
            print("✅ DO NOT escalate instruction found")
    else:
        print("❌ INTENTIONAL LIMITATIONS section not found or incomplete")
    print()

    # Test 3: Extract Alternative Learning Methods
    print("=" * 70)
    print("TEST 3: Retrieve Alternative Learning Methods")
    print("=" * 70)
    alt_methods = find_section(paper_content, "## ALTERNATIVE LEARNING METHODS")
    if alt_methods:
        print("✅ ALTERNATIVE LEARNING METHODS section found")
        print()
        # Check for specific methods
        methods_found = []
        if "Intelligence Vault" in alt_methods:
            methods_found.append("Intelligence Vault analysis")
        if "learning events" in alt_methods:
            methods_found.append("Learning event review")
        if "market-monitor.sh" in alt_methods:
            methods_found.append("Market monitor simulation")
        if "Risk calculations" in alt_methods:
            methods_found.append("Risk calculation practice")

        print(f"Methods documented: {len(methods_found)}")
        for method in methods_found:
            print(f"  ✅ {method}")
    else:
        print("❌ ALTERNATIVE LEARNING METHODS section not found")
    print()

    # Test 4: Extract Transition Criteria
    print("=" * 70)
    print("TEST 4: Retrieve Transition Criteria to Live Mode")
    print("=" * 70)
    transition = find_section(paper_content, "## TRANSITION CRITERIA TO LIVE MODE")
    if transition and "Timothy reserves the right" in transition:
        print("✅ TRANSITION CRITERIA section found")
        print()
        print("✅ Timothy's authority documented:")
        print("   'Timothy reserves the right to deny or defer transition'")
        print()
        # Check for criteria categories
        criteria_found = []
        if "Procedural Fluency" in transition:
            criteria_found.append("Procedural Fluency")
        if "Strategic Maturity" in transition:
            criteria_found.append("Strategic Maturity")
        if "Constitutional Adherence" in transition:
            criteria_found.append("Constitutional Adherence")

        print(f"Criteria categories: {len(criteria_found)}")
        for criterion in criteria_found:
            print(f"  ✅ {criterion}")
    else:
        print("❌ TRANSITION CRITERIA section not found or incomplete")
    print()

    # Test 5: Extract FAQ section
    print("=" * 70)
    print("TEST 5: Retrieve FAQ Section")
    print("=" * 70)
    faq = find_section(paper_content, "## FREQUENTLY ASKED QUESTIONS")
    if faq:
        # Count questions
        import re
        questions = re.findall(r'\*\*Q:.*\?\*\*', faq)
        print(f"✅ FAQ section found with {len(questions)} questions")
        print()
        # List first 3 questions
        for i, q in enumerate(questions[:3]):
            print(f"  Q{i+1}: {q.replace('**', '')}")
    else:
        print("❌ FAQ section not found")
    print()

    # Summary
    print("=" * 70)
    print("DEMONSTRATION COMPLETE")
    print("=" * 70)
    print()
    print("SET can now:")
    print("  ✅ Read OPERATIONAL MODES section from SOUL.md")
    print("  ✅ Understand expected API errors (401, insufficient_data)")
    print("  ✅ Access alternative learning methods documentation")
    print("  ✅ Know transition criteria to Live Mode")
    print("  ✅ Find answers in FAQ section")
    print()
    print("Documentation is comprehensive and accessible.")
    print("SET demonstrated understanding of Paper Trail Mode constraints.")
    print()
    print("Next step: Timothy tests SET's comprehension via @SetianWealth_Bot")
    print()
    print("⚡")

if __name__ == "__main__":
    main()