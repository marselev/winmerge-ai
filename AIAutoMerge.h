///////////////////////////////////////////////////////////////////////////
//
// WinMerge:  an interactive diff/merge utility
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
///////////////////////////////////////////////////////////////////////////
/**
 * @file  AIAutoMerge.h
 *
 * @brief Declaration of AI Auto Merge functionality
 *
 * This module provides AI-powered automatic merge capabilities for WinMerge.
 * Users can enable/disable AI auto-merge and select different merge strategies.
 */
#pragma once

#include "UnicodeString.h"
#include <vector>
#include <memory>

// Forward declarations
class CDiffTextBuffer;
struct DIFFRANGE;
class CMergeDoc;

/**
 * @brief AI Auto Merge strategies
 */
enum class AIAutoMergeStrategy
{
    CONSERVATIVE = 0,   ///< Prefer left side, only merge obvious changes
    BALANCED = 1,       ///< Balanced approach using context analysis
    AGGRESSIVE = 2,     ///< Prefer right side, merge most changes
    SMART = 3,          ///< Intelligent analysis based on code patterns
};

/**
 * @brief AI Auto Merge result
 */
struct AIAutoMergeResult
{
    bool success;
    int mergedCount;
    int conflictCount;
    String message;
};

/**
 * @brief AI Auto Merge manager class
 */
class AIAutoMergeManager
{
public:
    AIAutoMergeManager();
    ~AIAutoMergeManager();

    // Configuration
    void SetEnabled(bool enabled) { m_enabled = enabled; }
    bool IsEnabled() const { return m_enabled; }
    
    void SetStrategy(AIAutoMergeStrategy strategy) { m_strategy = strategy; }
    AIAutoMergeStrategy GetStrategy() const { return m_strategy; }
    
    // Main merge function
    AIAutoMergeResult PerformAutoMerge(CMergeDoc* pDoc, int dstPane);
    
    // Individual diff analysis and merge decision
    bool ShouldMergeDiff(const DIFFRANGE& diff, int srcPane, int dstPane);
    
    // Get strategy name for UI
    static String GetStrategyName(AIAutoMergeStrategy strategy);
    static std::vector<String> GetAllStrategyNames();

private:
    bool m_enabled;
    AIAutoMergeStrategy m_strategy;
    
    // Analysis functions for different strategies
    bool AnalyzeConservative(const DIFFRANGE& diff, int srcPane, int dstPane);
    bool AnalyzeBalanced(const DIFFRANGE& diff, int srcPane, int dstPane);
    bool AnalyzeAggressive(const DIFFRANGE& diff, int srcPane, int dstPane);
    bool AnalyzeSmart(const DIFFRANGE& diff, int srcPane, int dstPane);
    
    // Helper functions
    double CalculateChangeConfidence(const DIFFRANGE& diff, int srcPane, int dstPane);
    bool IsCodePatternMatch(const DIFFRANGE& diff, int srcPane, int dstPane);
    int CountSignificantChanges(const DIFFRANGE& diff);
};

/**
 * @brief Global AI Auto Merge manager instance
 */
AIAutoMergeManager* GetAIAutoMergeManager();
void InitAIAutoMergeManager();
void CleanupAIAutoMergeManager();
