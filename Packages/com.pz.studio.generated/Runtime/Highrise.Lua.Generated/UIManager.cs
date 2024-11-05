/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

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
    [AddComponentMenu("Lua/UIManager")]
    [LuaRegisterType(0x4420fd164eed93fa, typeof(LuaBehaviour))]
    public class UIManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "33342b1fd4649bd458922bd7fbbf73c3";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_BeeListObject = default;
        [SerializeField] public UnityEngine.GameObject m_BeeObtainCardObject = default;
        [SerializeField] public UnityEngine.GameObject m_PlaceApiaryObject = default;
        [SerializeField] public UnityEngine.GameObject m_CreateOrderGuiObject = default;
        [SerializeField] public UnityEngine.GameObject m_BeestiaryObject = default;
        [SerializeField] public UnityEngine.GameObject m_TutorialObject = default;
        [SerializeField] public UnityEngine.GameObject m_StatsObject = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_BeeListObject),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_BeeObtainCardObject),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_PlaceApiaryObject),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_CreateOrderGuiObject),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_BeestiaryObject),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_TutorialObject),
                CreateSerializedProperty(_script.GetPropertyAt(6), m_StatsObject),
            };
        }
    }
}

#endif