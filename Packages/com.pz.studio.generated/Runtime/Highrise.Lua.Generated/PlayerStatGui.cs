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
    [AddComponentMenu("Lua/PlayerStatGui")]
    [LuaRegisterType(0xa9ad8614a647b9e5, typeof(LuaBehaviour))]
    public class PlayerStatGui : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "f354c3220213f704192db8b48d16f990";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_BeeListObject = default;
        [SerializeField] public UnityEngine.GameObject m_ShopObject = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), null),
                CreateSerializedProperty(_script.GetPropertyAt(1), null),
                CreateSerializedProperty(_script.GetPropertyAt(2), null),
                CreateSerializedProperty(_script.GetPropertyAt(3), null),
                CreateSerializedProperty(_script.GetPropertyAt(4), null),
                CreateSerializedProperty(_script.GetPropertyAt(5), null),
                CreateSerializedProperty(_script.GetPropertyAt(6), null),
                CreateSerializedProperty(_script.GetPropertyAt(7), null),
                CreateSerializedProperty(_script.GetPropertyAt(8), null),
                CreateSerializedProperty(_script.GetPropertyAt(9), null),
                CreateSerializedProperty(_script.GetPropertyAt(10), null),
                CreateSerializedProperty(_script.GetPropertyAt(11), m_BeeListObject),
                CreateSerializedProperty(_script.GetPropertyAt(12), m_ShopObject),
            };
        }
    }
}

#endif
