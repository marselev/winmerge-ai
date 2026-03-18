///////////////////////////////////////////////////////////////////////////
//
// WinMerge:  an interactive diff/merge utility
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
///////////////////////////////////////////////////////////////////////////
/**
 * @file  AIAutoMerge.cpp
 *
 * @brief Implementation of AI Auto Merge functionality
 */
#include "pch.h"
#include "AIAutoMerge.h"
#include "MergeDoc.h"
#include "DiffTextBuffer.h"
#include "DiffList.h"
#include "OptionsMgr.h"
#include "OptionsDef.h"
#include <algorithm>
#include <cctype>

// Static global instance
static std::unique_ptr<AIAutoMergeManager> s_pAIAutoMergeManager;

AIAutoMergeManager::AIAutoMergeManager()
    : m_enabled(false)
    , m_strategy(AIAutoMergeStrategy::BALANCED)
{
}

AIAutoMergeManager::~AIAutoMergeManager() = default;

AIAutoMergeResult AIAutoMergeManager::PerformAutoMerge(CMergeDoc* pDoc, int dstPane)
{
    AIAutoMergeResult result = { false, 0, 0, _T("") };
    
    if (!pDoc || !m_enabled)
    {
        result.message = _T("AI Auto Merge is disabled");
        return result;
    }
    
    const int diffCount = pDoc->m_diffList.GetSize();
    if (diffCount == 0)
    {
        result.success = true;
        result.message = _T("No differences to merge");
        return result;
    }
    
    // Determine source pane (opposite of destination)
    int srcPane = (dstPane == 0) ? 1 : 0;
    if (pDoc->m_nBuffers == 3)
    {
        // For 3-way merge, use middle as reference
        if (dstPane == 0)
            srcPane = 1;
        else if (dstPane == 2)
            srcPane = 1;
        else
            srcPane = 0;
    }
    
    // Process each difference
    for (int i = 0; i < diffCount; ++i)
    {
        const DIFFRANGE* diff = pDoc->m_diffList.DiffRangeAt(i);
        if (!diff)
            continue;
            
        // Check if this diff should be merged based on strategy
        if (ShouldMergeDiff(*diff, srcPane, dstPane))
        {
            // Perform the merge
            if (pDoc->ListCopy(srcPane, dstPane, i))
            {
                result.mergedCount++;
            }
            else
            {
                result.conflictCount++;
            }
        }
        else
        {
            result.conflictCount++;
        }
    }
    
    result.success = (result.mergedCount > 0 || result.conflictCount == 0);
    
    // Build result message
    if (result.success)
    {
        result.message = strutils::format(
            _T("AI Auto Merge completed: %d changes merged, %d conflicts need manual resolution"),
            result.mergedCount, result.conflictCount);
    }
    else
    {
        result.message = _T("AI Auto Merge encountered errors");
    }
    
    return result;
}

bool AIAutoMergeManager::ShouldMergeDiff(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    switch (m_strategy)
    {
    case AIAutoMergeStrategy::CONSERVATIVE:
        return AnalyzeConservative(diff, srcPane, dstPane);
    case AIAutoMergeStrategy::BALANCED:
        return AnalyzeBalanced(diff, srcPane, dstPane);
    case AIAutoMergeStrategy::AGGRESSIVE:
        return AnalyzeAggressive(diff, srcPane, dstPane);
    case AIAutoMergeStrategy::SMART:
        return AnalyzeSmart(diff, srcPane, dstPane);
    default:
        return AnalyzeBalanced(diff, srcPane, dstPane);
    }
}

bool AIAutoMergeManager::AnalyzeConservative(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Conservative strategy: only merge if change is small and obvious
    
    // Check if it's a simple addition (no lines deleted)
    if (diff.begin[srcPane] == diff.end[srcPane] && diff.begin[dstPane] < diff.end[dstPane])
    {
        // Simple addition in destination - safe to merge from source
        return true;
    }
    
    // Check if it's a simple deletion (no lines added)
    if (diff.begin[dstPane] == diff.end[dstPane] && diff.begin[srcPane] < diff.end[srcPane])
    {
        // Simple deletion - only merge if it's a small change
        int linesDeleted = diff.end[srcPane] - diff.begin[srcPane];
        return linesDeleted <= 3;  // Only auto-merge small deletions
    }
    
    // For modifications, check size
    int srcLines = diff.end[srcPane] - diff.begin[srcPane];
    int dstLines = diff.end[dstPane] - diff.begin[dstPane];
    
    // Only merge if both sides have similar number of lines (simple modification)
    if (std::abs(srcLines - dstLines) <= 1 && srcLines <= 2)
    {
        return true;
    }
    
    return false;
}

bool AIAutoMergeManager::AnalyzeBalanced(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Balanced strategy: use context analysis
    
    // First apply conservative rules
    if (AnalyzeConservative(diff, srcPane, dstPane))
    {
        return true;
    }
    
    // For larger changes, calculate confidence score
    double confidence = CalculateChangeConfidence(diff, srcPane, dstPane);
    
    // Merge if confidence is high enough
    return confidence >= 0.7;
}

bool AIAutoMergeManager::AnalyzeAggressive(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Aggressive strategy: merge most changes except obvious conflicts
    
    // Don't merge if both sides have significant changes (conflict)
    int srcLines = diff.end[srcPane] - diff.begin[srcPane];
    int dstLines = diff.end[dstPane] - diff.begin[dstPane];
    
    // If both sides have many changes, it might be a conflict
    if (srcLines > 10 && dstLines > 10)
    {
        // Check if they're similar in nature
        double ratio = static_cast<double>(srcLines) / std::max(dstLines, 1);
        if (ratio < 0.5 || ratio > 2.0)
        {
            return false;  // Likely conflict
        }
    }
    
    // Merge everything else
    return true;
}

bool AIAutoMergeManager::AnalyzeSmart(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Smart strategy: use pattern matching and context analysis
    
    // First apply balanced analysis
    if (AnalyzeBalanced(diff, srcPane, dstPane))
    {
        return true;
    }
    
    // Check for code pattern matches
    if (IsCodePatternMatch(diff, srcPane, dstPane))
    {
        return true;
    }
    
    // Check confidence with higher threshold for smart mode
    double confidence = CalculateChangeConfidence(diff, srcPane, dstPane);
    return confidence >= 0.85;
}

double AIAutoMergeManager::CalculateChangeConfidence(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Calculate a confidence score (0.0 to 1.0) for the merge
    
    int srcLines = diff.end[srcPane] - diff.begin[srcPane];
    int dstLines = diff.end[dstPane] - diff.begin[dstPane];
    
    // Start with base confidence
    double confidence = 0.5;
    
    // Factor 1: Size similarity
    if (srcLines == dstLines)
    {
        confidence += 0.2;  // Same number of lines is good
    }
    else
    {
        double sizeRatio = static_cast<double>(std::min(srcLines, dstLines)) / 
                          std::max(srcLines, 1);
        confidence += sizeRatio * 0.15;
    }
    
    // Factor 2: Change size (smaller changes are more confident)
    int totalLines = srcLines + dstLines;
    if (totalLines <= 5)
    {
        confidence += 0.2;
    }
    else if (totalLines <= 10)
    {
        confidence += 0.1;
    }
    else if (totalLines > 50)
    {
        confidence -= 0.2;
    }
    
    // Factor 3: Simple additions/deletions are more confident
    if (srcLines == 0 || dstLines == 0)
    {
        confidence += 0.1;
    }
    
    return std::clamp(confidence, 0.0, 1.0);
}

bool AIAutoMergeManager::IsCodePatternMatch(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    // Check if the change follows common code patterns
    // This is a simplified implementation
    
    // For now, just check if it looks like a comment change
    // or whitespace-only change
    
    // TODO: Implement more sophisticated pattern matching
    // - Check for variable renaming patterns
    // - Check for function signature changes
    // - Check for import/include changes
    
    return false;
}

int AIAutoMergeManager::CountSignificantChanges(const DIFFRANGE& diff)
{
    // Count non-trivial changes in the diff
    // This is a placeholder for more sophisticated analysis
    
    return 0;
}

String AIAutoMergeManager::GetStrategyName(AIAutoMergeStrategy strategy)
{
    switch (strategy)
    {
    case AIAutoMergeStrategy::CONSERVATIVE:
        return _T("Conservative");
    case AIAutoMergeStrategy::BALANCED:
        return _T("Balanced");
    case AIAutoMergeStrategy::AGGRESSIVE:
        return _T("Aggressive");
    case AIAutoMergeStrategy::SMART:
        return _T("Smart");
    default:
        return _T("Unknown");
    }
}

std::vector<String> AIAutoMergeManager::GetAllStrategyNames()
{
    return {
        GetStrategyName(AIAutoMergeStrategy::CONSERVATIVE),
        GetStrategyName(AIAutoMergeStrategy::BALANCED),
        GetStrategyName(AIAutoMergeStrategy::AGGRESSIVE),
        GetStrategyName(AIAutoMergeStrategy::SMART)
    };
}

// Global functions
AIAutoMergeManager* GetAIAutoMergeManager()
{
    if (!s_pAIAutoMergeManager)
    {
        InitAIAutoMergeManager();
    }
    return s_pAIAutoMergeManager.get();
}

void InitAIAutoMergeManager()
{
    s_pAIAutoMergeManager = std::make_unique<AIAutoMergeManager>();
    
    // Load settings from options
    COptionsMgr* pOptions = GetOptionsMgr();
    if (pOptions)
    {
        bool enabled = pOptions->GetBool(OPT_AI_AUTO_MERGE_ENABLED);
        int strategy = pOptions->GetInt(OPT_AI_AUTO_MERGE_STRATEGY);
        
        s_pAIAutoMergeManager->SetEnabled(enabled);
        s_pAIAutoMergeManager->SetStrategy(static_cast<AIAutoMergeStrategy>(strategy));
    }
}

void CleanupAIAutoMergeManager()
{
    s_pAIAutoMergeManager.reset();
}
