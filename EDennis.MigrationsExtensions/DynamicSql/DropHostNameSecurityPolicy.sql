IF EXISTS (SELECT 0 FROM sys.security_predicates sp WHERE OBJECT_ID('[@SecuritySchema].[@SecurityPolicyName]') = sp.object_id)
	DROP SECURITY POLICY [@SecuritySchema].[@SecurityPolicyName]


