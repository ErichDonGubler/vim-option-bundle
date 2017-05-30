let s:option_bundles = {}

fun! GetOpposite(truthy)
	if a:truthy
		return 0
	else
		return 1
	endif
endfun

fun! option_bundle#create(bundle_name, is_enabled_by_default, flags_list)
	let l:bundle = {
				\ 'bundle_name': a:bundle_name,
				\ 'is_globally_enabled': GetOpposite(a:is_enabled_by_default),
				\ 'flags_list': a:flags_list,
				\ 'enabled_for_buffer': {},
				\ }

	fun! l:bundle._SetOption(should_enable, is_local) dict
		let l:setter = 'set'
		if a:is_local
			let l:setter = l:setter . 'local'
		endif

		let l:modifier = a:should_enable ? '' : 'no'
		for l:flag in self.flags_list
			execute l:setter . ' ' . l:modifier . l:flag
		endfor
	endfun

	fun! l:bundle.IsGlobalEnabled() dict
		return self.is_globally_enabled
	endfun

	fun! l:bundle.SetGlobalTo(should_enable) dict
		if self.is_globally_enabled != a:should_enable
			let self.is_globally_enabled = a:should_enable
			call self._SetOption(a:should_enable, 0)
		endif
	endfun

	fun! l:bundle.ToggleGlobal() dict
		let l:toggle_flag = GetOpposite(self.IsGlobalEnabled())
		call self.SetGlobalTo(l:toggle_flag)
	endfun

	fun! l:bundle.IsLocalEnabled() dict
		let l:buffer_id = bufnr('%')
		if !has_key(self.enabled_for_buffer, l:buffer_id)
			let self.enabled_for_buffer[l:buffer_id] = self.is_globally_enabled
		endif
		return self.enabled_for_buffer[l:buffer_id]
	endfun

	fun! l:bundle.SetLocalTo(should_enable) dict
		if self.IsLocalEnabled() != a:should_enable
			let l:buffer_id = bufnr('%')
			let self.enabled_for_buffer[l:buffer_id] = a:should_enable
			call self._SetOption(a:should_enable, 1)
		endif
	endfun

	fun! l:bundle.ToggleLocal() dict
		let l:toggle_flag = GetOpposite(self.IsLocalEnabled())
		call self.SetLocalTo(l:toggle_flag)
	endfun

	let s:option_bundles[a:bundle_name] = l:bundle
	call l:bundle.SetGlobalTo(a:is_enabled_by_default)
	return l:bundle
endfun

