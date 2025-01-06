/*

    Copyright (c) 2025 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;
using Highrise.Studio;
using Highrise.Lua;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/WildBeeManager")]
    [LuaRegisterType(0xead08ae944742586, typeof(LuaBehaviour))]
    public class WildBeeManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "c8909c5bd53db154087508055992cfe1";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_CommonBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_StoneBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_ForestBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_AquaticBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_GiantBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_SilverBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_MuddyBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_FrigidBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_SteelBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_MagmaBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_GhostlyBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_IridescentBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_SandyBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_AutumnalBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_PetalBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_GalacticBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_IndustrialBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_PearlescentBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_HypnoticBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_RadiantBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_ShadowBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_PrismaticBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_AstralBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_RainbowBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_MeadowBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_BronzeBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_OceanicBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_RubyBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_CamoBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_CrystalBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_TechnoBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_PsychedelicBeePrefab = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_CommonBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_StoneBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_ForestBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_AquaticBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_GiantBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_SilverBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(6), m_MuddyBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(7), m_FrigidBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(8), m_SteelBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(9), m_MagmaBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(10), m_GhostlyBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(11), m_IridescentBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(12), m_SandyBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(13), m_AutumnalBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(14), m_PetalBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(15), m_GalacticBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(16), m_IndustrialBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(17), m_PearlescentBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(18), m_HypnoticBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(19), m_RadiantBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(20), m_ShadowBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(21), m_PrismaticBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(22), m_AstralBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(23), m_RainbowBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(24), m_MeadowBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(25), m_BronzeBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(26), m_OceanicBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(27), m_RubyBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(28), m_CamoBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(29), m_CrystalBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(30), m_TechnoBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(31), m_PsychedelicBeePrefab),
            };
        }
    }
}

#endif
