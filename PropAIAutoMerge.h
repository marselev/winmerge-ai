///////////////////////////////////////////////////////////////////////////
//
// WinMerge:  an interactive diff/merge utility
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
///////////////////////////////////////////////////////////////////////////
/**
 * @file  PropAIAutoMerge.h
 *
 * @brief Property page for AI Auto Merge settings
 */
#pragma once

#include "OptionsPanel.h"
#include "AIAutoMerge.h"

class COptionsMgr;

/**
 * @brief Property page for AI Auto Merge settings
 */
class PropAIAutoMerge : public OptionsPanel
{
public:
    PropAIAutoMerge(COptionsMgr* options);
    ~PropAIAutoMerge() override;

    // Implement IOptionsPanel
    void ReadOptions() override;
    void WriteOptions() override;

protected:
    // Dialog Data
    BOOL m_bAIAutoMergeEnabled;
    int m_nAIAutoMergeStrategy;

    //{{AFX_DATA(PropAIAutoMerge)
    enum { IDD = IDD_PROP_AI_AUTO_MERGE };
    //}}AFX_DATA

    //{{AFX_VIRTUAL(PropAIAutoMerge)
protected:
    void DoDataExchange(CDataExchange* pDX) override;
    BOOL OnInitDialog() override;
    //}}AFX_VIRTUAL

    //{{AFX_MSG(PropAIAutoMerge)
    afx_msg void OnEnableAIAutoMergeClicked();
    afx_msg void OnStrategyChanged();
    //}}AFX_MSG

    DECLARE_MESSAGE_MAP()

private:
    void UpdateControls();
};
