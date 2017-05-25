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
				\ 'is_globally_enabled': GetOpposite(a:is_enabled_by_default),
				\ 'flags_list': a:flags_list,
				\ 'enabled_for_buffer': {}
				\ }

	fun! _set_options(should_enable, is_local) dict
		let l:setter = 'set'
		if a:is_local
			let l:setter = l:setter . 'local'
		endif

		let l:modifier = a:should_enable ? '' : 'no'
		for l:flag in self.flags_list
			execute l:setter . ' ' . l:modifier . l:flag
		endfor

		echo (a:should_enable ? 'Enabled' : 'Disabled') . (a:is_local ? ' local ' : ' ') . a:bundle_name
	endfun

	fun! is_global_enabled() dict
		return self.is_globally_enabled
	endfun

	fun! set_global(should_enable) dict
		if self.is_globally_enabled != a:should_enable
			self.is_globally_enabled = a:should_enable
			self._set_options(a:should_enable, 0)
		endif
	endfun

	fun! toggle_global() dict
		let l:toggle_flag = GetOpposite(self.is_global_enabled())
		call self.set_global_to(l:toggle_flag)
	endfun

	fun! is_local_enabled() dict
		return self.enabled_for_buffer[bufnr('%')]

	fun! set_local(should_enable) dict
		let l:buffer_id = bufnr('%')
		if self.enabled_for_buffer[l:buffer_id]
			let self.enabled_for_buffer[l:buffer_id] = a:should_enable
			call self._set_options(a:should_enable, 1)
	endfun

	fun! toggle_local() dict
		let l:toggle_flag = GetOpposite(self.is_local_enabled())
		call self.set_local_to(l:toggle_flag)
	endfun

	let s:option_bundles[a:bundle_name] = l:bundle
	call l:bundle.set_global_to(a:is_enabled_by_default, 0)
	return l:bundle
endfun

